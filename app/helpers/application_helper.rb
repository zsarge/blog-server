module ApplicationHelper
  def normalize_url(url)
    return if url.blank?

    uri = URI.parse(url.strip)
    uri.scheme ? url : "https://#{url}"
  rescue URI::InvalidURIError
    "#"
  end

  def display_url(url)
    truncate(url.sub(/\Ahttps?:\/\//, ''), length: 20)
  end
end
