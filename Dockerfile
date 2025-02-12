# Use official NGINX image as the base
FROM nginx:alpine

# Remove default NGINX config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy HTML files
COPY html /usr/share/nginx/html

# Expose port 80 for ECS
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
