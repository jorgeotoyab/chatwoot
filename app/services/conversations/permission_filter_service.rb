class Conversations::PermissionFilterService
  attr_reader :conversations, :user, :account

  def initialize(conversations, user, account)
    @conversations = conversations
    @user = user
    @account = account
  end

  def perform
    # YasuiTV: los chats de contactos privados se excluyen ANTES del early
    # return de administradores — solo los viewers autorizados los ven.
    scoped = conversations
    unless Yasuitv::RestrictedChats.allowed?(user)
      scoped = scoped.where.not(contact_id: Yasuitv::RestrictedChats.restricted_contact_ids(account))
    end

    return scoped if user_role == 'administrator'

    accessible_conversations(scoped)
  end

  private

  def accessible_conversations(scoped)
    scoped.where(inbox: user.inboxes.where(account_id: account.id))
  end

  def account_user
    AccountUser.find_by(account_id: account.id, user_id: user.id)
  end

  def user_role
    account_user&.role
  end
end

Conversations::PermissionFilterService.prepend_mod_with('Conversations::PermissionFilterService')
