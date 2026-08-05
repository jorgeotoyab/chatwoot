# YasuiTV: chats privados a nivel de contacto.
#
# Un contacto marcado con el atributo personalizado `chat_privado` (checkbox
# en el panel de contacto) solo es visible —conversaciones, búsqueda y
# búsqueda de contactos— para los usuarios de YASUITV_RESTRICTED_VIEWER_IDS
# (default: 5 = Jordan). Solo esos usuarios pueden marcar/desmarcar el flag.
# Nivel de ocultamiento acordado: listas y búsquedas (el acceso directo por
# URL no se bloquea). Las conversaciones de contactos privados tampoco entran
# a la auto-asignación (quedan sin asignar hasta que el autorizado las tome).
module Yasuitv
  module RestrictedChats
    ATTRIBUTE_KEY = 'chat_privado'.freeze
    TRUTHY = %w[true t 1].freeze

    def self.viewer_ids
      ENV.fetch('YASUITV_RESTRICTED_VIEWER_IDS', '5').split(',').map(&:to_i)
    end

    def self.allowed?(user)
      user.present? && viewer_ids.include?(user.id)
    end

    def self.restricted_contact_ids(account)
      account.contacts
             .where("contacts.custom_attributes ->> '#{ATTRIBUTE_KEY}' IN (?)", TRUTHY)
             .select(:id)
    end

    def self.restricted?(contact)
      TRUTHY.include?(contact&.custom_attributes&.[](ATTRIBUTE_KEY).to_s)
    end
  end
end
