# frozen_string_literal: true
# Opens FitsDocument class from Hydra::Works::Characterization
# and adds fits mapping for extra technical metadata
Hydra::Works::Characterization::FitsDocument.class_eval do
  def file_path
    ng_xml.css("fits > fileinfo > filepath").map(&:text)
  end

  def creating_os
    ng_xml.css("fits > fileinfo > creatingos").map(&:text)
  end

  def creating_application_name
    ng_xml.css("fits > fileinfo > creatingApplicationName").map(&:text)
  end

  def puid
    ng_xml.css("fits > identification > identity > externalIdentifier[type='puid']").map(&:text)
  end
end
