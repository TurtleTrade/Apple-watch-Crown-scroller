# Static site for "publishing" a landing page (App Store links, description).
# This does NOT build or host the iOS/watchOS app — use Xcode + App Store Connect for that.
FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/public /usr/share/nginx/html
EXPOSE 8080
