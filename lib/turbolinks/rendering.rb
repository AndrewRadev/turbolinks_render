module Turbolinks
  module Rendering
    def render(*args, &block)
      if render_with_turbolinks?
        render_with_turbolinks(*args, &block)
      else
        super
      end
    end

    private

    def render_with_turbolinks?
      request.xhr? && !request.get?
    end

    def render_with_turbolinks(*args, &block)
      html = render_to_string(*args, &block)
      self.response_body = build_turbolinks_response_to_render(html)
      self.status = 200
      response.content_type = 'text/javascript'
    end

    def build_turbolinks_response_to_render(html)
      escaped_html = ActionController::Base.helpers.j(html)

      <<-JS
    (function(){
      Turbolinks.clearCache();
      var parser = new DOMParser();
      var newDocument = parser.parseFromString("#{escaped_html}", "text/html");

      document.documentElement.replaceChild(newDocument.body, document.body);
      Turbolinks.dispatch('turbolinks:load');
      window.scroll(0, 0);
    })();
      JS
    end
  end
end

AbstractController::Rendering.prepend(Turbolinks::Rendering)
