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

  if AuthConfig.use_database_auth?
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  else
    devise_for :users, skip: [:sessions, :registrations, :passwords],
                       controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  end

  devise_scope :user do
    get 'auth/failure', to: 'users/omniauth_callbacks#failure'
    post '/auth/saml/callback', to: 'omniauth_callbacks#saml', as: 'user_omniauth_callback'
    post '/auth/saml', to: 'omniauth_callbacks#passthru', as: 'user_omniauth_authorize'
    get 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session unless AuthConfig.use_database_auth?
    match 'saml_redirect' => 'application#saml_redirect', as: :saml_redirect, via: [:get]
  end

  resources :background_jobs, only: [:new, :create]

  mount Hydra::RoleManagement::Engine => '/'

  # Require authentication by an admin user to mount sidekiq web ui
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

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

  match '/404', to: 'errors#not_found', via: :all, as: :not_found_error
  match '/422', to: 'errors#unprocessable', via: :all, as: :unprocessable_error
  match '/500', to: 'errors#unhandled_exception', via: :all

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
