class SyncAccumulateChangesJob < ActiveJob::Base
  queue_as :default

  def perform(sync_run_id)
    sync_run = SyncRun.find(sync_run_id)
    sync_run.accumulate_changes

    # copy objects to stores
    unless sync_run.has_conflicts?
      SyncApplyChangesJob.perform_later(sync_run_id)
    end
  end
end

