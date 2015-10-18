defmodule CentralGPS.Repo.Permissions do
  def security do
    %{
      feature: "SECURITY",
      entity: %{
        account: %{list: "SECURITY_ENTITY_ACCOUNT_L" },
        account_role: %{list: "SECURITY_ENTITY_ACCOUNT_ROLE_L"},
    	  account_permission: %{list: "SECURITY_ENTITY_ACCOUNT_PERMISSION_L"},
      },
      client: %{
        account: %{list: "SECURITY_CLIENT_ACCOUNT_L" },
        account_role: %{list: "SECURITY_CLIENT_ACCOUNT_ROLE_L"},
    	  account_permission: %{list: "SECURITY_CLIENT_ACCOUNT_PERMISSION_L"},
      }
    }
  end
  def checkpoint do
    %{
      feature: "CHECKPOINT",
      report:  %{read: "CHECKPOINT_REPORT_R"},
      monitor: %{read: "CHECKPOINT_MONITOR_R"},
      form:  %{list: "CHECKPOINT_FORM_L" },
      form_template:  %{list: "CHECKPOINT_FORM_TEMPLATE_L" },
      client:  %{list: "CHECKPOINT_CLIENT_L" },
      client_contact:  %{list: "CHECKPOINT_CLIENT_CONTACT_L" },
      item:  %{list: "CHECKPOINT_ITEM_L" },
      measure_unit:  %{list: "CHECKPOINT_MEASURE_UNIT_L" },
      activity:  %{list: "CHECKPOINT_ACTIVITY_L" },
      venue:   %{list: "CHECKPOINT_VENUE_L" },
      activity_role:  %{list: "CHECKPOINT_ACTIVITY_ROLE_L" },
      venue_type:   %{list: "CHECKPOINT_VENUE_TYPE_L" },
      mark: %{list: "CHECKPOINT_MARK_L", manager_list: "CHECKPOINT_MANAGER_MARK_L"}
    }
  end
  def client do
    %{
      feature: "CLIENT",
      asset: %{
        monitor: %{list: "CLIENT_ASSET_MONITOR_L", manager_list: "CLIENT_ASSET_MONITOR_MANAGER_L"}
      },
      roadmap: %{
        list: "CLIENT_ROADMAP_L",
        point: %{ list: "CLIENT_ROADMAP_POINT_L", }
      }
    }
  end

# TODO: use fn_api_account_permission_check for the reengineering of this section

  @doc """
  Does the session contains this permission (accesible through the permission map objects)
  """
  def check(user_permissions, permission) do
    try do
      Enum.find_value user_permissions, false, &(&1 == permission)
    rescue
      _ in KeyError -> false
    end
  end

  @doc """
  If session.permissions contains a permission on the specific section of
  permissions...
  """
  def contains(usr_perm, perm_obj) do
    Enum.find (for u <- usr_perm, do:
      (if (check map_to_list(perm_obj), u), do: true, else: false)),
      false, &(&1 == true)
  end

  def map_to_list(obj) do
    if(is_map obj) do
      List.flatten(for m <- obj, do: map_to_list m)
    else
      if (is_tuple obj) do
        elem(obj, 1) |> map_to_list
      else
        obj
      end
    end
  end

end
