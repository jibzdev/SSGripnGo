module ApplicationHelper
  include SeoHelper
  def active_class(link_path)
    current_page?(link_path) ? "hover:bg-gray-100 dark:hover:bg-zinc-700 hover:text-black dark:hover:text-white bg-gray-100 dark:bg-zinc-700 text-black dark:text-white text-zinc-950 dark:text-zinc-50 hover:text-zinc-950 dark:hover:text-zinc-50" : "text-gray-600 dark:text-gray-300"
  end

  def category_open?(paths)
    Rails.logger.debug "Checking paths: #{paths.inspect}"
    Rails.logger.debug "Current page: #{request.path}"
    paths.any? { |path| current_page?(path) } ? 'block' : 'hidden'
  end

  def status_badge_class(status)
    case status.to_s
    when 'confirmed', 'fulfilled', 'paid'
      'bg-green-500/20 text-green-400'
    when 'pending', 'unpaid'
      'bg-yellow-500/20 text-yellow-400'
    when 'processing', 'unfulfilled', 'awaiting_payment'
      'bg-blue-500/20 text-blue-400'
    when 'cancelled', 'refunded'
      'bg-red-500/20 text-red-400'
    else
      'bg-gray-500/20 text-gray-400'
    end
  end

  def formatted_address(address)
    return content_tag(:span, 'No address on file', class: 'text-ssgrip-silver-dark') if address.blank?

    normalized = address.with_indifferent_access
    lines = [
      normalized[:line1],
      normalized[:line2],
      [normalized[:city], normalized[:region]].compact_blank.join(', ').presence,
      normalized[:postal_code],
      normalized[:country] || 'United Kingdom'
    ].compact_blank

    safe_join(lines.map { |line| content_tag(:span, line) }, tag.br)
  end
end