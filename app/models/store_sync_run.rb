class StoreSyncRun < ApplicationRecord
  belongs_to :store
  belongs_to :sync_run
end