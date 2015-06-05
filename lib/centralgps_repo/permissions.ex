defmodule CentralGPS.Repo.Permissions do
  def security do
    %{
      entity: %{
        account: %{create: "SECURITY_ENTITY_ACCOUNT_C", read: "SECURITY_ENTITY_ACCOUNT_R", update: "SECURITY_ENTITY_ACCOUNT_U", delete: "SECURITY_ENTITY_ACCOUNT_D", list: "SECURITY_ENTITY_ACCOUNT_L" },
        account_role: %{create: "SECURITY_ENTITY_ACCOUNT_ROLE_C", delete: "SECURITY_ENTITY_ACCOUNT_ROLE_D", list: "SECURITY_ENTITY_ACCOUNT_ROLE_L"},
    	  account_permission: %{create: "SECURITY_ENTITY_ACCOUNT_PERMISSION_C", delete: "SECURITY_ENTITY_ACCOUNT_PERMISSION_D", list: "SECURITY_ENTITY_ACCOUNT_PERMISSION_L"},
      },
      client: %{
        account: %{create: "SECURITY_CLIENT_ACCOUNT_C", read: "SECURITY_CLIENT_ACCOUNT_R", update: "SECURITY_CLIENT_ACCOUNT_U", delete: "SECURITY_CLIENT_ACCOUNT_D", list: "SECURITY_CLIENT_ACCOUNT_L" },
        account_role: %{create: "SECURITY_CLIENT_ACCOUNT_ROLE_C", delete: "SECURITY_CLIENT_ACCOUNT_ROLE_D", list: "SECURITY_CLIENT_ACCOUNT_ROLE_L"},
    	  account_permission: %{create: "SECURITY_CLIENT_ACCOUNT_PERMISSION_C", delete: "SECURITY_CLIENT_ACCOUNT_PERMISSION_D", list: "SECURITY_CLIENT_ACCOUNT_PERMISSION_L"},
      }
    }
  end
  def checkpoint do
    %{
      report:  %{read: "CHECKPOINT_REPORT_R"},
      monitor: %{read: "CHECKPOINT_MONITOR_R"},
      action:  %{create: "CHECKPOINT_ACTION_C", read: "CHECKPOINT_ACTION_R", update: "CHECKPOINT_ACTION_U", delete: "CHECKPOINT_ACTION_D", list: "CHECKPOINT_ACTION_L" },
      reason:  %{create: "CHECKPOINT_REASON_C", read: "CHECKPOINT_REASON_R", update: "CHECKPOINT_REASON_U", delete: "CHECKPOINT_REASON_D", list: "CHECKPOINT_REASON_L" },
      venue:   %{create: "CHECKPOINT_VENUE_C", read: "CHECKPOINT_VENUE_R", update: "CHECKPOINT_VENUE_U", delete: "CHECKPOINT_VENUE_D", list: "CHECKPOINT_VENUE_L" },
      reason_role:  %{create: "CHECKPOINT_REASON_ROLE_C", read: "CHECKPOINT_REASON_ROLE_R", update: "CHECKPOINT_REASON_ROLE_U", delete: "CHECKPOINT_REASON_ROLE_D", list: "CHECKPOINT_REASON_ROLE_L" },
      venue_type:   %{create: "CHECKPOINT_VENUE_TYPE_C", read: "CHECKPOINT_VENUE_TYPE_R", update: "CHECKPOINT_VENUE_TYPE_U", delete: "CHECKPOINT_VENUE_TYPE_D", list: "CHECKPOINT_VENUE_TYPE_L" },
      mark: %{create: "CHECKPOINT_MARK_C", list: "CHECKPOINT_MARK_L", manager_list: "CHECKPOINT_MANAGER_MARK_L"}
    }
  end
  def client do
    %{
      asset: %{
        monitor: %{list: "CLIENT_ASSET_MONITOR_L", manager_list: "CLIENT_ASSET_MONITOR_MANAGER_L"}
      }
    }
  end

  @doc """
  Does the session contains this permission (accesible through the permission map objects)
  """
  def check(user_permissions, permission) do
    Enum.find_value user_permissions, false, &(&1 == permission)
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
