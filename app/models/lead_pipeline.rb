# frozen_string_literal: true

class LeadPipeline < ApplicationRecord
  belongs_to :account
  belongs_to :contact
  belongs_to :conversation
  belongs_to :assigned_user, class_name: 'User', optional: true

  validates :current_stage, presence: true

  # As labels são a "fonte da verdade" desse pipeline.
  # Esta tabela atua apenas como índice de leitura rápida para o Kanban
  # de modo a evitar joins custosos na hora de carregar os quadros.

  STAGES = %w[new qualified negotiation followup freezer closed lost].freeze

  validates :current_stage, inclusion: { in: STAGES }
end
