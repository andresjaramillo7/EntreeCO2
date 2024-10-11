using Microsoft.AspNetCore.Mvc;
using EntreeCO2.Data;
using EntreeCO2.Models;
using Microsoft.AspNetCore.Authorization;

namespace EntreeCO2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsuariosController : ControllerBase
    {
        private readonly UsuarioDatos _usuarioDatos;

        public UsuariosController()
        {
            _usuarioDatos = new UsuarioDatos();
        }

        [HttpGet("{id}")]
        public IActionResult GetUsuario(int id)
        {
            try
            {
                var usuario = _usuarioDatos.ObtenerUsuario(id);
                if (usuario == null)
                {
                    return NotFound();
                }
                return Ok(usuario);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error: " + ex.Message);
            }
        }

        [HttpPost("validar")]
        public IActionResult ValidarUsuario([FromBody] ValidacionUsuarioModel model)
        {
            try
            {
                var rolUsuario = _usuarioDatos.ValidarUsuario(model.IdUsuario, model.Contraseña);
                if (rolUsuario != null)
                {
                    return Ok(new { Message = "Usuario validado exitosamente.", Rol = rolUsuario });
                }
                return Unauthorized("Credenciales no válidas.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error: " + ex.Message);
            }
        }

        [HttpPost]
        public IActionResult CrearUsuario([FromBody] UsuarioModel usuario)
        {
            try
            {
                _usuarioDatos.CrearUsuario(usuario);
                return CreatedAtAction(nameof(GetUsuario), new { id = usuario.IdUsuario }, usuario);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error: " + ex.Message);
            }
        }

        [Authorize(Roles = "administrador")]
        public IActionResult GetSensitiveData()
        {
            return Ok("Datos Sensibles");
        }
    }
}