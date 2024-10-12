using Npgsql;
using BCrypt;
using EntreeCO2.Models;
using System.Data;

namespace EntreeCO2.Data
{
    public class UsuarioDatos
    {
        private readonly string _connectionString = "tu_cadena_de_conexion_aqui";
        public UsuarioModel ObtenerUsuario(int idUsuario)
        {
            UsuarioModel usuario = null;
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("SELECT * FROM Usuarios WHERE id_usuario = @IdUsuario", con);
                cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        usuario = new UsuarioModel
                        {
                            IdUsuario = Convert.ToInt32(dr["id_usuario"]),
                            NombreUsuario = dr["nombre_usuario"].ToString(),
                            Email = dr["email"].ToString(),
                            Contraseña = dr["contraseña"].ToString(),
                            TipoUsuario = dr["tipo_usuario"].ToString(),
                            IdRestaurante = dr.IsDBNull(dr.GetOrdinal("id_restaurante")) ? null : (int?)dr["id_restaurante"]
                        };
                    }
                }
            }
            return usuario;
        }

        public void CrearUsuario(UsuarioModel usuario)
        {
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("INSERT INTO Usuarios (nombre_usuario, email, contraseña, tipo_usuario, id_restaurante) VALUES (@NombreUsuario, @Email, @ContraseñaHash, @TipoUsuario, @IdRestaurante)", con);
                cmd.Parameters.AddWithValue("@NombreUsuario", usuario.NombreUsuario);
                cmd.Parameters.AddWithValue("@Email", usuario.Email);
                cmd.Parameters.AddWithValue("@ContraseñaHash", BCrypt.Net.BCrypt.HashPassword(usuario.Contraseña));
                cmd.Parameters.AddWithValue("@TipoUsuario", usuario.TipoUsuario);
                cmd.Parameters.AddWithValue("@IdRestaurante", usuario.IdRestaurante ?? (object)DBNull.Value);

                cmd.ExecuteNonQuery();
            }
        }

        public string ValidarUsuario(int idUsuario, string contraseña)
        {
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("SELECT contraseña, tipo_usuario FROM Usuarios WHERE id_usuario = @IdUsuario", con);
                cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read() && BCrypt.Net.BCrypt.Verify(contraseña, dr["contraseña"].ToString()))
                    {
                        return dr["tipo_usuario"].ToString();
                    }
                }
            }
            return null;
        }
        private bool VerificarContraseña(string contraseñaPlana, string contraseñaHash)
        {
            return BCrypt.Net.BCrypt.Verify(contraseñaPlana, contraseñaHash);
        }

    }
}