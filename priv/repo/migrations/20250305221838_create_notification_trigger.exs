defmodule PubsubExample.Repo.Migrations.CreateNotificationTriggerForBancos do
  @moduledoc """
  Esta migración solo funciona en PostgreSQL.
  """
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION notify_bancos() RETURNS TRIGGER AS $$
    BEGIN
      PERFORM pg_notify('bancos', json_build_object(
        'tipo', TG_OP,
        'id', NEW.id,
        'id_delete', OLD.id
      )::text);
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER bancos_trigger
    AFTER INSERT OR UPDATE OR DELETE ON bancos
    FOR EACH ROW EXECUTE FUNCTION notify_bancos();
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS bancos_trigger ON bancos;")
    execute("DROP FUNCTION IF EXISTS notify_bancos();")
  end
end
