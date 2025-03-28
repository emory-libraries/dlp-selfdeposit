# frozen_string_literal: true
module SelfDeposit
  class ValkyrieFixityService
    extend ActiveSupport::Concern

    attr_accessor :target

    # @param [String, RDF::URI] target url for a Fedora resource.
    def initialize(object)
      raise ArgumentError, 'You must provide a Fileset object' unless object
      @target = object.original_file.file_identifier.to_s.gsub('fedora', 'http')
    end

    def response
      @response ||= fixity_response_from_fedora
    end

    # For backwards compat, check always insists on doing a new request.
    # you might want verified? instead which uses a cached request.
    # @return true or false
    def check
      @response = nil
      verified?
    end

    # Executes a fixity check on Fedora
    # @return true or false
    def verified?
      status.include?(success)
    end

    # An array of 1 or more literals reported by Fedora.
    # See 'success' for which one indicates fixity check is good.
    def status
      fixity_graph.query({ predicate: premis_status_predicate }).map(&:object) +
        fixity_graph.query({ predicate: fedora_status_predicate }).map(&:object)
    end

    # the currently calculated checksum, as a string URI, like
    # "urn:sha1:09a848b79f86f3a4f3f301b8baafde455d6f8e0e"
    def expected_message_digest
      'urn:sha1:' + object_sha1_value
    end

    # integer, as reported by fedora. bytes maybe?
    def expected_size
      fixity_graph.query({ predicate: ::RDF::Vocab::PREMIS.hasSize }).first.try(:object).try(:to_s).try(:to_i)
    end

    # Fedora response as an ::RDF::Graph object. Public API, so consumers
    # can do with it what they will, especially if future fedora versions
    # add more things to it.
    def response_graph
      fixity_graph
    end

    private

    def premis_status_predicate
      ::RDF::Vocab::PREMIS.hasEventOutcome
    end

    # Fcrepo4.status was used by Fedora < 4.3, but it was removed
    # from the 2015-07-24 version of the fedora 4 ontology
    # http://fedora.info/definitions/v4/2015/07/24/repository and
    # from rdf-vocab in version 0.8.5
    def fedora_status_predicate
      ::RDF::URI("http://fedora.info/definitions/v4/repository#status")
    end

    def success
      ::RDF::Literal.new("SUCCESS")
    end

    def fixity_response_from_fedora
      uri = @target + "/fcr:fixity"
      Hyrax.query_service.adapter.connection.get(uri)
    end

    def fixity_graph
      @fixity_graph ||= ::RDF::Graph.new << ::RDF::Reader.for(:ttl).new(response.body)
    end

    def object_sha1_value
      response = Hyrax.query_service.adapter.connection.get(@target) do |req|
        req.headers["Want-Digest"] = 'sha'
      end
      response.response.env.response_headers["digest"].split('sha=').last
    end
  end
end
