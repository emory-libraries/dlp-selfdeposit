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

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # unless AuthConfig.use_database_auth?
  devise_scope :user do
    get 'sign_in', to: 'omniauth#new'
    post 'sign_in', to: 'users/omniauth_callbacks#saml'
    get 'sign_out', to: 'devise/sessions#destroy'
    get 'auth/failure', to: 'users/omniauth_callbacks#failure'
  end
  # end

  mount Hydra::RoleManagement::Engine => '/'

  mount Sidekiq::Web => '/sidekiq'
  match "queue-latency" => proc {
                             [200, { "Content-Type" => "text/plain" }, [latency_text]]
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
  def latency_text
    Sidekiq::Queue.all.map do |q|
      "#{q.name} queue latency in seconds: #{q.latency}"
    end.join(', ')
  end
end
