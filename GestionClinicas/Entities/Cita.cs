using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GestionClinicas.Entities
{
    public class Cita
    {
        int CitaID { get; set; }
        int PacienteID { get; set; }
        int DoctorID { get; set; }
        DateTime Fecha { get; set; }
        DateTime Hora { get; set; }
        string Estado { get; set; } // Pendiente, Completada, Cancelada
    }
}
