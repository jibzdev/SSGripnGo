require 'csv'

class VehicleDatasetLookup
  DATA_PATH = Rails.root.join('app/assets/mmm.csv')
  DATA_MUTEX = Mutex.new

  class << self
    def lookup(make:, model: nil)
      return nil if make.blank?

      dataset = dataset_index[normalize(make)]
      return nil unless dataset

      entry = nil
      target = normalize(model) if model.present?

      if target.present?
        entry = dataset[:by_model][target] ||
                dataset[:by_gen_model][target] ||
                fuzzy_match(dataset[:entries], target)
      end

      entry ||= dataset[:default_entry]
      entry ? format_entry(entry) : nil
    end

    def refresh_cache!
      DATA_MUTEX.synchronize do
        @dataset_index = nil
        @dataset_mtime = nil
      end
      dataset_index
    end

    private

    def dataset_index
      current_mtime = File.exist?(DATA_PATH) ? File.mtime(DATA_PATH).to_i : 0

      DATA_MUTEX.synchronize do
        if @dataset_index.nil? || @dataset_mtime != current_mtime
          @dataset_index = load_dataset
          @dataset_mtime = current_mtime
        end
        @dataset_index
      end
    end

    def load_dataset
      index = {}
      seen = {}

      CSV.foreach(DATA_PATH, headers: true) do |row|
        make_raw = row['Make']
        model_raw = row['Model']
        gen_model_raw = row['GenModel']
        descriptor = model_raw.presence || gen_model_raw.presence

        next if make_raw.blank? || descriptor.blank?

        normalized_make = normalize(make_raw)
        normalized_model = normalize(model_raw)
        normalized_gen_model = normalize(gen_model_raw)
        dedupe_key = [normalized_make, normalized_model, normalized_gen_model].join(':')
        next if seen[dedupe_key]
        seen[dedupe_key] = true

        entry = {
          make: make_raw.strip,
          model: model_raw&.strip,
          gen_model: gen_model_raw&.strip,
          body_descriptor: descriptor.strip,
          normalized_model: normalized_model,
          normalized_gen_model: normalized_gen_model
        }

        collection = (index[normalized_make] ||= base_collection)
        collection[:entries] << entry
        collection[:default_entry] ||= entry
        collection[:by_model][normalized_model] ||= entry if normalized_model.present?
        collection[:by_gen_model][normalized_gen_model] ||= entry if normalized_gen_model.present?
      end

      index
    rescue Errno::ENOENT
      Rails.logger.warn("VehicleDatasetLookup could not find CSV file at #{DATA_PATH}")
      {}
    rescue => e
      Rails.logger.error("VehicleDatasetLookup failed to load dataset: #{e.message}")
      {}
    end

    def base_collection
      {
        entries: [],
        by_model: {},
        by_gen_model: {},
        default_entry: nil
      }
    end

    def fuzzy_match(entries, target)
      entries.find do |entry|
        normalized = entry[:normalized_model]
        normalized.present? && (target.include?(normalized) || normalized.include?(target))
      end || entries.find do |entry|
        normalized = entry[:normalized_gen_model]
        normalized.present? && (target.include?(normalized) || normalized.include?(target))
      end
    end

    def format_entry(entry)
      {
        make: entry[:make],
        model: entry[:model],
        gen_model: entry[:gen_model],
        body_descriptor: entry[:body_descriptor]
      }
    end

    def normalize(value)
      value.to_s.strip.upcase.gsub(/[^A-Z0-9]/, '')
    end
  end
end

