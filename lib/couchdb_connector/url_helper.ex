defmodule Couchdb.Connector.UrlHelper do
  @moduledoc """
  Provides URL helper functions that compose URLs based on given database
  properties and additional parameters, such as document IDs, usernames, etc.

  Most of the time, these functions will be used internally. There should
  rarely be a need to access these from within your application.
  """

  alias Couchdb.Connector.Types

  @doc """
  Produces the URL to the server given in db_props, using no authentication.
  """
  @spec database_server_url(Types.db_properties) :: String.t
  def database_server_url db_props do
    "#{db_props[:protocol]}://#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Produces the URL to the server given in db_props including
  basic auth parameters.
  """
  @spec database_server_url(Types.db_properties, Types.basic_auth) :: String.t
  def database_server_url(db_props, auth) do
    "#{db_props[:protocol]}://#{auth[:user]}:#{auth[:password]}@#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Produces the URL to a specific database hosted on the given server.
  """
  @spec database_url(Types.db_properties) :: String.t
  def database_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}"
  end

  @doc """
  Produces the URL to a specific database hosted on the given server including
  basic auth parameters.
  """
  @spec database_url(Types.db_properties, Types.basic_auth) :: String.t
  def database_url(db_props, auth) do
    "#{database_server_url(db_props, auth)}/#{db_props[:database]}"
  end

  @doc """
  Produces the URL to a specific document contained in given database.
  """
  @spec document_url(Types.db_properties, String.t) :: String.t
  def document_url(db_props, id) do
    "#{database_server_url(db_props)}/#{db_props[:database]}/#{id}"
  end

  @spec document_url(Types.db_properties, Types.basic_auth, String.t) :: String
.t
  def document_url(db_props, auth, id) do
    "#{database_url(db_props, auth)}/#{id}"
  end

  @doc """
  Produces a url to insert a specific attachment in the database 
  using no authentication. See attachment_url/5 for more information.
  """
  @spec attachment_insert_url(Types.db_properties, String.t, String.t, String.t)
  :: String.t
  def attachment_insert_url(db_props, id, att_name, rev) do
    "#{document_url(db_props, id)}/#{att_name}?rev=#{rev}"
  end

  @doc """
  Produces a url to fetch a specific attachment in the database 
  using no authentication. See attachment_url/5 for more information.
  """
  @spec attachment_fetch_url(Types.db_properties, String.t, String.t, String.t)
  :: String.t
  def attachment_fetch_url(db_props, id, att_name, rev) do
    "#{document_url(db_props, id)}/#{att_name}"
  end

  @doc """
  Produces the URL to insert a specific attachment to a rev of a 
  document contained in given database, making use of basic authentication. 
  Attachments inserted in CouchDB apply to a specific revision of a document.  
  Note that the attachment name is local to the code and not on the server.
  """
  @spec attachment_insert_url(Types.db_properties, Types.basic_auth, String.t, 
                       String.t, String.t) :: String.t
  def attachment_insert_url(db_props, auth, id, att_name, rev) do
    "#{document_url(db_props, auth, id)}/#{att_name}?rev=#{rev}"
  end

  # MFK
  @doc """
  Produces the URL to retrieve a specific attachment of a 
  document contained in given database, making use of basic authentication. 
  Attachments inserted in CouchDB apply to a specific revision of a document.  
  Note that the attachment name is local to the code and not on the server.
  However, the revision of the document is not needed for retrieval.
  """
  @spec attachment_fetch_url(Types.db_properties, Types.basic_auth, String.t, 
                       String.t) :: String.t
  def attachment_fetch_url(db_props, auth, id, att_name) do
    "#{document_url(db_props, auth, id)}/#{att_name}"
  end

  @doc """
  Produces an URL that can be used to retrieve the given number of UUIDs from
  CouchDB. Authentication is not required.
  """
  @spec fetch_uuid_url(Types.db_properties, non_neg_integer) :: String.t
  def fetch_uuid_url db_props, count \\ 1 do
    "#{database_server_url(db_props)}/_uuids?count=#{count}"
  end

  @doc """
  Produces the URL to a specific design document, using no authentication.
  """
  @spec design_url(Types.db_properties, String.t) :: String.t
  def design_url db_props, design do
    "#{database_server_url(db_props)}/#{db_props[:database]}/_design/#{design}"
  end

  @doc """
  Produces the URL to a specific design document, using basic authentication.
  """
  @spec design_url(Types.db_properties, Types.basic_auth, String.t) :: String.t
  def design_url db_props, auth, design do
    "#{database_server_url(db_props, auth)}/#{db_props[:database]}/_design/#{design}"
  end

  @doc """
  Produces the URL to a specific view from a given design document, using no
  authentication.
  """
  @spec view_url(Types.db_properties, String.t, String.t) :: String.t
  def view_url db_props, design, view do
    "#{design_url(db_props, design)}/_view/#{view}"
  end

  @doc """
  Produces the URL to a specific view from a given design document, making use
  of basic authentication.
  """
  @spec view_url(Types.db_properties, Types.basic_auth, String.t, String.t) :: String.t
  def view_url db_props, auth, design, view do
    "#{design_url(db_props, auth, design)}/_view/#{view}"
  end

  @doc """
  Produces the URL to query a view for a specific key, using the provided
  staleness setting (either :ok or :update_after).
  """
  @spec query_path(String.t, String.t, atom) :: String.t
  def query_path view_base_url, key, stale do
    "#{view_base_url}?key=\"#{URI.encode_www_form(key)}\"&stale=#{Atom.to_string(stale)}"
  end

  @doc """
  Produces the URL to a specific user, providing no authentication.
  """
  @spec user_url(Types.db_properties, String.t) :: String.t
  def user_url db_props, username do
    "#{database_server_url(db_props)}/_users/org.couchdb.user:#{username}"
  end

  @doc """
  Produces the URL to a specific user, applying the given admin credentials.
  Use this to create a new user, given the callers knows some admin credentials.
  """
  @spec user_url(Types.db_properties, Types.basic_auth, String.t) :: String.t
  def user_url(db_props, admin_auth, username) do
    "#{database_server_url(db_props, admin_auth)}/_users/org.couchdb.user:#{username}"
  end

  @doc """
  Produces the URL to a specific admin, using no authentication
  """
  @spec admin_url(Types.db_properties, String.t) :: String.t
  def admin_url db_props, username do
    "#{database_server_url(db_props)}/_config/admins/#{username}"
  end

  @doc """
  Produces the URL to a specific admin, including basic auth params.
  """
  @spec admin_url(Types.db_properties, String.t, String.t) :: String.t
  def admin_url db_props, admin_name, password do
    "#{database_server_url(db_props, %{user: admin_name, password: password})}/_config/admins/#{admin_name}"
  end

  @doc """
  Produces the URL to the database's security object. Requires admin
  credentials.
  """
  @spec security_url(Types.db_properties, Types.basic_auth) :: String.t
  def security_url db_props, admin_auth do
    "#{database_url(db_props, admin_auth)}/_security"
  end
end
