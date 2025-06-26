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

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(REDCARPET_OPTIONS)
    markdown = Redcarpet::Markdown.new(renderer, REDCARPET_EXTENSIONS)
    markdown.render(text).html_safe
  end

  private

  REDCARPET_OPTIONS = {
    filter_html: true,
    hard_wrap: true,
    link_attributes: { rel: 'nofollow', target: "_blank" },
    space_after_headers: true,
    fenced_code_blocks: true,
    no_images: true,
  }

  REDCARPET_EXTENSIONS = {
    autolink: true,
    superscript: true,
    disable_indented_code_blocks: true
  }

end
