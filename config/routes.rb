# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/api'

Rails.application.routes.draw do
  mount Bulkrax::Engine, at: '/'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount BrowseEverything::Engine => '/browse'

  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  resources :background_jobs, only: [:new, :create]

  devise_for :users, controllers: { saml_sessions: 'saml_sessions' }

  mount Hydra::RoleManagement::Engine => '/'

  mount Sidekiq::Web => '/sidekiq'
  match "queue-latency" => proc {
                             [200, { "Content-Type" => "application/json" }, [latency_text]]
                           }, via: :get
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  get 'purl/:emory_persistent_id', to: 'purl#redirect_to_original'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # rubocop:disable Rails/FindEach
  def latency_text
    ret_hsh = { queues: [] }
    Sidekiq::Queue.all.each do |q|
      ret_hsh[:queues] << Hash[q.name, q.latency]
    end
    ret_hsh.to_json
  end
  # rubocop:enable Rails/FindEach
end
