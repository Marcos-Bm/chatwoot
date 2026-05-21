# rubocop:disable all
class Api::V1::Accounts::PipelinesController < Api::V1::Accounts::BaseController
  before_action :fetch_pipelines, only: [:index]

  def index
    # Retornamos os cards agrupados por estágio para facilitar no frontend
    payload = LeadPipeline::STAGES.each_with_object({}) do |stage, hash|
      hash[stage] = @pipelines.select { |p| p.current_stage == stage }.map do |pipeline|
        {
          id: pipeline.id,
          conversation_id: pipeline.conversation_id,
          contact_id: pipeline.contact_id,
          current_stage: pipeline.current_stage,
          assigned_user_id: pipeline.assigned_user_id,
          score: pipeline.score,
          updated_at: pipeline.updated_at,
          # Campos calculados da conversation / contact
          contact_name: pipeline.contact.name,
          contact_avatar: pipeline.contact.avatar_url,
          contact_phone_number: pipeline.contact.phone_number,
          inbox_name: pipeline.conversation.inbox&.name,
          assignee_name: pipeline.assigned_user&.name,
          labels: pipeline.conversation.labels.pluck(:title),
          last_activity_at: pipeline.conversation.last_activity_at,
          messages_preview: pipeline.conversation.messages.last&.content
        }
      end
    end

    render json: { payload: payload }
  end

  private

  def fetch_pipelines
    @pipelines = Current.account.lead_pipelines.includes(:contact, :assigned_user, conversation: [:inbox, :labels, :messages])
  end
end
