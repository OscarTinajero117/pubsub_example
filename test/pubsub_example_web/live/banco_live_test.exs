defmodule PubsubExampleWeb.BancoLiveTest do
  use PubsubExampleWeb.ConnCase

  import Phoenix.LiveViewTest
  import PubsubExample.CatalogosFixtures

  @create_attrs %{descripcion: "some descripcion", clabe: "some clabe"}
  @update_attrs %{descripcion: "some updated descripcion", clabe: "some updated clabe"}
  @invalid_attrs %{descripcion: nil, clabe: nil}

  defp create_banco(_) do
    banco = banco_fixture()
    %{banco: banco}
  end

  describe "Index" do
    setup [:create_banco]

    test "lists all bancos", %{conn: conn, banco: banco} do
      {:ok, _index_live, html} = live(conn, ~p"/bancos")

      assert html =~ "Listing Bancos"
      assert html =~ banco.descripcion
    end

    test "saves new banco", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bancos")

      assert index_live |> element("a", "New Banco") |> render_click() =~
               "New Banco"

      assert_patch(index_live, ~p"/bancos/new")

      assert index_live
             |> form("#banco-form", banco: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#banco-form", banco: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bancos")

      html = render(index_live)
      assert html =~ "Banco created successfully"
      assert html =~ "some descripcion"
    end

    test "updates banco in listing", %{conn: conn, banco: banco} do
      {:ok, index_live, _html} = live(conn, ~p"/bancos")

      assert index_live |> element("#bancos-#{banco.id} a", "Edit") |> render_click() =~
               "Edit Banco"

      assert_patch(index_live, ~p"/bancos/#{banco}/edit")

      assert index_live
             |> form("#banco-form", banco: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#banco-form", banco: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bancos")

      html = render(index_live)
      assert html =~ "Banco updated successfully"
      assert html =~ "some updated descripcion"
    end

    test "deletes banco in listing", %{conn: conn, banco: banco} do
      {:ok, index_live, _html} = live(conn, ~p"/bancos")

      assert index_live |> element("#bancos-#{banco.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bancos-#{banco.id}")
    end
  end

  describe "Show" do
    setup [:create_banco]

    test "displays banco", %{conn: conn, banco: banco} do
      {:ok, _show_live, html} = live(conn, ~p"/bancos/#{banco}")

      assert html =~ "Show Banco"
      assert html =~ banco.descripcion
    end

    test "updates banco within modal", %{conn: conn, banco: banco} do
      {:ok, show_live, _html} = live(conn, ~p"/bancos/#{banco}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Banco"

      assert_patch(show_live, ~p"/bancos/#{banco}/show/edit")

      assert show_live
             |> form("#banco-form", banco: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#banco-form", banco: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bancos/#{banco}")

      html = render(show_live)
      assert html =~ "Banco updated successfully"
      assert html =~ "some updated descripcion"
    end
  end
end
