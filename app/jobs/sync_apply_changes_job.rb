class SyncApplyChangesJob < ActiveJob::Base
  queue_as :default

  def perform(sync_run_id)
    sync_run = SyncRun.find(synch_run_id)
    sync_run.apply_changes
  end
end
