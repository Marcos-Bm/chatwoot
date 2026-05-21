class PipelineListener < BaseListener
  def conversation_created(event)
    conversation = extract_conversation_and_account(event)[0]
    sync_pipeline(conversation)
  end

  def conversation_updated(event)
    conversation = extract_conversation_and_account(event)[0]
    sync_pipeline(conversation)
  end

  private

  def sync_pipeline(conversation)
    # Procuramos se existe alguma label no conversation que inicie com "pipeline:"
    # O pipeline label é a fonte da verdade.
    pipeline_labels = conversation.labels.where("title LIKE 'pipeline:%'").pluck(:title)
    
    if pipeline_labels.present?
      # Pode haver mais de um (o que é uma anomalia), mas pegaremos o primeiro
      # Formato esperado da label: 'pipeline:new', 'pipeline:qualified', etc
      stage = pipeline_labels.first.split(':').last

      # Apenas salva se o estágio for reconhecido no Kanban
      if LeadPipeline::STAGES.include?(stage)
        pipeline = LeadPipeline.find_or_initialize_by(conversation_id: conversation.id)
        pipeline.account_id = conversation.account_id
        pipeline.contact_id = conversation.contact_id
        pipeline.current_stage = stage
        pipeline.assigned_user_id = conversation.assignee_id
        pipeline.save!
      end
    else
      # Se o card existia mas a label foi removida, também removemos do cache
      pipeline = LeadPipeline.find_by(conversation_id: conversation.id)
      pipeline&.destroy
    end
  end
end
