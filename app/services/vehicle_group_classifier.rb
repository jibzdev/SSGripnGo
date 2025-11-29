class VehicleGroupClassifier
  BODY_TYPE_MAPPINGS = {
    /HATCH/ => 'hatchback',
    /SALOON|SEDAN/ => 'saloon',
    /ESTATE|WAGON|TOURER/ => 'estate',
    /COUPE|ROADSTER|CABRIO/ => 'coupe',
    /SUV|SPORT UTILITY|4X4|CROSSOVER/ => 'suv',
    /PICK.?UP|TRUCK/ => 'pickup',
    /MPV|MINIVAN|MULTI PURPOSE/ => 'mpv'
  }.freeze

  MODEL_KEYWORDS = {
    'coupe' => %w[coupe roadster spider],
    'suv' => %w[suv cross sportback xtrail x1 x2 x3 x5 q3 q5 q7 gla glb gle gls],
    'estate' => %w[estate tourer wagon avant touring],
    'hatchback' => %w[hatchback hatch fiesta polo golf clio a1 a3 yaris civic],
    'saloon' => %w[saloon sedan],
    'pickup' => %w[pickup ranger l200 hilux dmax],
    'mpv' => %w[mpv sharan galaxy touran scenic]
  }.freeze

  def initialize(vehicle_payload)
    @vehicle_payload = (vehicle_payload || {}).with_indifferent_access
    enrich_from_dataset!
  end

  def detect
    return explicit_match if explicit_match.present?
    inferred_code = detect_from_body_type || detect_from_model || detect_from_keywords || detect_from_group_rules
    return nil unless inferred_code

    VehicleGroup.active.find_by(code: inferred_code)
  end

  private

  def enrich_from_dataset!
    return if @vehicle_payload.blank?

    make = @vehicle_payload[:make]
    needs_enrichment = make.present? && (@vehicle_payload[:body_type].blank? || @vehicle_payload[:model].blank?)
    return unless needs_enrichment

    model_candidate = @vehicle_payload[:model].presence || @vehicle_payload[:vehicle_model]
    dataset_entry = VehicleDatasetLookup.lookup(make: make, model: model_candidate)
    return unless dataset_entry

    @vehicle_payload[:model] ||= dataset_entry[:model] || dataset_entry[:gen_model]
    @vehicle_payload[:body_type] ||= dataset_entry[:body_descriptor]
  end

  def explicit_match
    VehicleGroup.active.find_by(code: @vehicle_payload[:vehicle_group_code]) if @vehicle_payload[:vehicle_group_code]
  end

  def detect_from_body_type
    body_type = normalize(@vehicle_payload[:body_type] || @vehicle_payload['body_type'])
    return nil if body_type.blank?

    BODY_TYPE_MAPPINGS.each do |regex, code|
      return code if body_type.match?(regex)
    end
    nil
  end

  def detect_from_model
    model = normalize(@vehicle_payload[:model] || @vehicle_payload['model'])
    return nil if model.blank?

    MODEL_KEYWORDS.each do |code, keywords|
      return code if keywords.any? { |keyword| model.include?(keyword) }
    end
    nil
  end

  def detect_from_keywords
    description = [
      @vehicle_payload[:make],
      @vehicle_payload[:model],
      @vehicle_payload[:vehicle_type],
      @vehicle_payload[:body_type]
    ].compact.map { |value| normalize(value) }.join(' ')

    return nil if description.blank?

    BODY_TYPE_MAPPINGS.each do |regex, code|
      return code if description.match?(regex)
    end
    nil
  end

  def detect_from_group_rules
    description = [
      @vehicle_payload[:body_type],
      @vehicle_payload[:model],
      @vehicle_payload[:gen_model]
    ].compact.map { |value| normalize(value) }.join(' ')

    return nil if description.blank?

    VehicleGroup.active.each do |group|
      keywords = group.matching_keywords
      next if keywords.blank?

      normalized_keywords = keywords.map { |keyword| normalize(keyword) }.reject(&:blank?)
      next if normalized_keywords.empty?

      return group.code if normalized_keywords.any? { |keyword| description.include?(keyword) }
    end
    nil
  end

  def normalize(value)
    value.to_s.strip.upcase
  end
end

