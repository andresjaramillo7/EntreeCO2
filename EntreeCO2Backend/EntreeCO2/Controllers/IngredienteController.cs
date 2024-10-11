using EntreeCO2.Data;
using EntreeCO2.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EntreeCO2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IngredientesController : ControllerBase
    {
        private readonly IngredienteDatos _ingredienteDatos;

        public IngredientesController(IngredienteDatos ingredienteDatos)
        {
            _ingredienteDatos = ingredienteDatos;
        }

        // GET: api/ingredientes
        [HttpGet]
        [Authorize]  // Asegura que solo los usuarios autenticados pueden acceder
        public ActionResult<List<IngredienteModel>> GetIngredientes()
        {
            return _ingredienteDatos.ListarIngredientes();
        }

        // POST: api/ingredientes
        [HttpPost]
        [Authorize(Roles = "administrador")]  // Solo los administradores pueden agregar ingredientes
        public IActionResult AddIngrediente([FromBody] IngredienteModel ingrediente)
        {
            _ingredienteDatos.InsertarIngrediente(ingrediente.Nombre, ingrediente.PesoCarbono);
            return Ok("Ingrediente agregado exitosamente.");
        }

        // PUT: api/ingredientes/{id}
        [HttpPut("{id}")]
        [Authorize(Roles = "administrador")]  // Solo los administradores pueden actualizar ingredientes
        public IActionResult UpdateIngrediente(int id, [FromBody] IngredienteModel ingrediente)
        {
            _ingredienteDatos.ActualizarIngrediente(id, ingrediente.Nombre, ingrediente.PesoCarbono);
            return Ok("Ingrediente actualizado exitosamente.");
        }

        // DELETE: api/ingredientes/{id}
        [HttpDelete("{id}")]
        [Authorize(Roles = "administrador")]  // Solo los administradores pueden eliminar ingredientes
        public IActionResult DeleteIngrediente(int id)
        {
            _ingredienteDatos.EliminarIngrediente(id);
            return Ok("Ingrediente eliminado exitosamente.");
        }
    }
}
