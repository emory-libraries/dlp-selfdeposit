# frozen_string_literal: true
class CatalogController < ApplicationController
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    "system_create_dtsi"
  end

  def self.modified_field
    "system_modified_dtsi"
  end

  configure_blacklight do |config|
    config.view.slideshow(document_component: Blacklight::Gallery::SlideshowComponent)

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Hyrax::CatalogSearchBuilder

    # Show gallery view
    config.view.slideshow.partials = [:index]

    # Because too many times on Samvera tech people raise a problem regarding a failed query to SOLR.
    # Often, it's because they inadvertently exceeded the character limit of a GET request.
    config.http_method = Hyrax.config.solr_default_method

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    default_solr_search_fields = ["title_tesim", "id", "deduplication_key_ssi", "system_of_record_ID_ssi", "emory_persistent_id_ssi",
                                  "final_published_versions_tesim", "publisher_tesim", "grant_agencies_tesim", "grant_information_tesim",
                                  "creator_tesim"]
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: default_solr_search_fields.join(' ')
    }

    # solr field configuration for document/show views
    config.index.title_field = "title_tesim"
    config.index.display_type_field = "has_model_ssim"
    config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)
    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)
    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field "creator_last_first_ssim", label: "Authors", limit: 10
    config.add_facet_field "date_issued_year_ssi", label: "Date", limit: 10
    config.add_facet_field "parent_title_ssi", label: "Journal or Parent Publication Title", limit: 10
    config.add_facet_field "content_genre_ssi", label: "Type", limit: 10
    config.add_facet_field "publisher_version_ssi", label: "Publication Version", limit: 10
    config.add_facet_field "keyword_sim", label: 'Keyword', limit: 10

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field "title_tesim", label: "Title", itemprop: 'name', if: false
    config.add_index_field "creator_ssim", label: 'Authors', itemprop: 'creator', helper_method: :emory_creators_display
    config.add_index_field "date_issued_year_tesi", label: "Date"
    config.add_index_field "publisher_tesim", itemprop: 'publisher'
    config.add_index_field "publisher_version_tesi", itemprop: 'publisherVersion', label: 'Publication Version'
    config.add_index_field "license_tesi", helper_method: :license_links, label: 'License'
    config.add_index_field Hydra.config.permissions.embargo.release_date, label: "Embargo release date", helper_method: :human_readable_date
    config.add_index_field Hydra.config.permissions.lease.expiration_date, label: "Lease expiration date", helper_method: :human_readable_date
    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # Emory Note: the fields are no longer dynamically delivered via this config setting.
    #   Instead, they are hard coded in views/hyrax/base/_attribute_rows.html.erb. We, in turn,
    #   have overridden tht partial so we can institute our own choices/order.
    config.add_show_field "emory_persistent_id_ssi"
    config.add_show_field "content_genre_tesi"
    config.add_show_field "title_tesim"
    config.add_show_field "creator_tesim"
    config.add_show_field "language_tesim"
    config.add_show_field "date_issued_tesi"
    config.add_show_field "publisher_tesim"
    config.add_show_field "publisher_version_tesi"
    config.add_show_field "parent_title_tesi"
    config.add_show_field "conference_name_tesi"
    config.add_show_field "issn_tesi"
    config.add_show_field "isbn_tesi"
    config.add_show_field "series_title_tesi"
    config.add_show_field "grant_agencies_tesim"
    config.add_show_field "grant_information_tesim"
    config.add_show_field "abstract_tesim"
    config.add_show_field "author_notes_tesi"
    config.add_show_field "keyword_tesim"
    config.add_show_field "subject_tesim"
    config.add_show_field "research_categories_tesim"
    config.add_show_field "emory_ark_tesim"

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = "title_tesim"
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_tsimv",
        pf: title_name.to_s
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = "contributor_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      solr_name = "creator_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      solr_name = "title_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Description"
      solr_name = "description_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      solr_name = "publisher_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      solr_name = "created_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('content_genre') do |field|
      solr_name = 'content_genre_ssi'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      solr_name = "subject_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      solr_name = "language_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      solr_name = "resource_type_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('format') do |field|
      solr_name = "format_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      solr_name = "id_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      solr_name = "based_near_label_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('keyword') do |field|
      solr_name = "keyword_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = "depositor_ssim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('rights_statement') do |field|
      solr_name = "rights_statement_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('license') do |field|
      solr_name = "license_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('research_categories') do |field|
      solr_name = "research_categories_ssim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('parent_title') do |field|
      solr_name = "parent_title_ssi"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher_version') do |field|
      solr_name = "publisher_version_ssi"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "date_issued_year_ssi desc", label: "date \u25BC"
    config.add_sort_field "date_issued_year_ssi asc", label: "date \u25B2"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end
