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

# Ejemplo para crear un solo trigger para todas las tablas:
# def up do
#   execute("""
#   CREATE OR REPLACE FUNCTION notify_changes() RETURNS TRIGGER AS $$
#   DECLARE
#     record_id INTEGER;
#   BEGIN
#     IF TG_OP = 'DELETE' THEN
#       record_id := OLD.id;
#     ELSE
#       record_id := NEW.id;
#     END IF;

#     PERFORM pg_notify('changes', json_build_object(
#       'tabla', TG_TABLE_NAME,
#       'tipo', TG_OP,
#       'id', record_id
#     )::text);

#     RETURN NEW;
#   END;
#   $$ LANGUAGE plpgsql;
#   """)

#   tables = ["bancos", "clientes", "usuarios", "bitacora"]

#   for table <- tables do
#     execute("CREATE TRIGGER #{table}_trigger AFTER INSERT OR UPDATE OR DELETE ON #{table} FOR EACH ROW EXECUTE FUNCTION notify_changes();")
#   end
# end

# def down do
#   tables = ["bancos", "clientes", "usuarios", "bitacora"]

#   for table <- tables do
#     execute("DROP TRIGGER IF EXISTS #{table}_trigger ON #{table};")
#   end

#   execute("DROP FUNCTION IF EXISTS notify_changes();")
# end
