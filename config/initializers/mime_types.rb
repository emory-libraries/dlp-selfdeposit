# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/ld+json", :jsonld
Mime::Type.register "application/n-triples", :nt
Mime::Type.register 'application/x-endnote-refer', :endnote
Mime::Type.register "image/svg+xml", :svg
Mime::Type.register "text/css", :css
Mime::Type.register "text/turtle", :ttl
Rack::Mime::MIME_TYPES['.mjs'] = 'application/javascript'
