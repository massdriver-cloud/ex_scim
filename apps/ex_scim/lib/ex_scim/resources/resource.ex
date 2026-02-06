defprotocol ExScim.Resources.Resource do
  @moduledoc """
  Protocol for SCIM resource operations.
  """

  def get_id(resource)
  def get_external_id(resource)
  def set_id(resource, id)
end
