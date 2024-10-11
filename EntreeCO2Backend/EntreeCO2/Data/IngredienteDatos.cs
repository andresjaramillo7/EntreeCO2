using EntreeCO2.Models;
using Npgsql;

namespace EntreeCO2.Data
{
    public class IngredienteDatos
    {
        private readonly string _connectionString;

        public IngredienteDatos(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void InsertarIngrediente(string nombre, decimal pesoCarbono)
        {
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("CALL InsertarIngrediente(@Nombre, @PesoCarbono)", con);
                cmd.Parameters.AddWithValue("@Nombre", nombre);
                cmd.Parameters.AddWithValue("@PesoCarbono", pesoCarbono);
                cmd.ExecuteNonQuery();
            }
        }

        public void ActualizarIngrediente(int idIngrediente, string nombre, decimal pesoCarbono)
        {
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("CALL ActualizarIngrediente(@IdIngrediente, @Nombre, @PesoCarbono)", con);
                cmd.Parameters.AddWithValue("@IdIngrediente", idIngrediente);
                cmd.Parameters.AddWithValue("@Nombre", nombre);
                cmd.Parameters.AddWithValue("@PesoCarbono", pesoCarbono);
                cmd.ExecuteNonQuery();
            }
        }

        public void EliminarIngrediente(int idIngrediente)
        {
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("CALL EliminarIngrediente(@IdIngrediente)", con);
                cmd.Parameters.AddWithValue("@IdIngrediente", idIngrediente);
                cmd.ExecuteNonQuery();
            }
        }

        public List<IngredienteModel> ListarIngredientes()
        {
            var ingredientes = new List<IngredienteModel>();
            using (var con = new NpgsqlConnection(_connectionString))
            {
                con.Open();
                var cmd = new NpgsqlCommand("CALL ListarIngredientes()", con);
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ingredientes.Add(new IngredienteModel
                        {
                            IdIngrediente = Convert.ToInt32(dr["id_ingrediente"]),
                            Nombre = dr["nombre"].ToString(),
                            PesoCarbono = Convert.ToDecimal(dr["peso_carbono"])
                        });
                    }
                }
            }
            return ingredientes;
        }
    }
}
