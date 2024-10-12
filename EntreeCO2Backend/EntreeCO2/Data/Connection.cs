using Npgsql;

namespace EntreeCO2.Data
{
    public class Connection
    {
        NpgsqlConnection conn = new NpgsqlConnection();
        string cadena = "server=localhost;port=5432;user id=postgres;password=AndresDev77.;database=Northec;";

        public NpgsqlConnection OpenConexion()
        {
            try
            {
                conn.ConnectionString = cadena;
                conn.Open();
            }
            catch (NpgsqlException e)
            {
                string error = e.Message;
            }
            return conn;
        }

        public void CloseConexion()
        {
            try
            {
                conn.Close();
            }
            catch (NpgsqlException e)
            {
                string er = e.Message;
            }
        }
    }
}
