CREATE DATABASE Gestion_clinicas;
USE Gestion_clinicas;

-- Pacientes
CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    FechaNacimiento DATE,
    Direccion NVARCHAR(255),
    Telefono NVARCHAR(20)
);

-- Tabla: Doctores (Se modifica columna horario y se pasa a una tabla)
CREATE TABLE Doctores (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Especializacion NVARCHAR(100),
    Telefono NVARCHAR(20)
);

-- Tabla: HorariosDoctores (La que se pasó)
CREATE TABLE HorariosDoctores (
    HorarioID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT,
    DiaSemana INT,           -- 1=Lunes, 7=Domingo...
    HoraInicio TIME,
    HoraFin TIME,
    FOREIGN KEY (DoctorID) REFERENCES Doctores(DoctorID)
);

-- Tabla: Citas
CREATE TABLE Citas (
    CitaID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT,
    DoctorID INT,
    Fecha DATE,
    Hora TIME,
    Estado NVARCHAR(20), -- Pendiente, Completada, Cancelada
    FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID),
    FOREIGN KEY (DoctorID) REFERENCES Doctores(DoctorID)
);

-- Tabla: Tratamientos
CREATE TABLE Tratamientos (
    TratamientoID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT,
    TipoTratamiento NVARCHAR(100),
    FechaInicio DATE,
    Duracion INT, -- Días
    CostoTotal DECIMAL(10,2),
    SaldoPendiente DECIMAL(10,2),
    FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID)
);

-- Tabla: Pagos
CREATE TABLE Pagos (
    PagoID INT PRIMARY KEY IDENTITY(1,1),
    TratamientoID INT,
    FechaPago DATE,
    Monto DECIMAL(10,2),
    MetodoPago NVARCHAR(50),
    FOREIGN KEY (TratamientoID) REFERENCES Tratamientos(TratamientoID)
);
GO;

--SP Registrar cita
CREATE PROCEDURE SP_RegistrarCita
    @PacienteID INT,
    @DoctorID INT,
    @Fecha DATE,
    @Hora TIME
AS
BEGIN
    DECLARE @DiaSemana INT = DATEPART(WEEKDAY, @Fecha);

    -- Validar que el doctor trabaje ese día y hora
    IF NOT EXISTS (
        SELECT 1 FROM HorariosDoctores
        WHERE DoctorID = @DoctorID
          AND DiaSemana = @DiaSemana
          AND @Hora BETWEEN HoraInicio AND HoraFin
    )
    BEGIN
        RAISERROR('El doctor no trabaja en esa fecha y hora.', 16, 1);
        RETURN;
    END

    -- Validar que no tenga una cita a esa hora
    IF EXISTS (
        SELECT 1 FROM Citas
        WHERE DoctorID = @DoctorID
          AND Fecha = @Fecha
          AND Hora = @Hora
    )
    BEGIN
        RAISERROR('El doctor ya tiene una cita en ese horario.', 16, 1);
        RETURN;
    END

    -- Registrar cita
    INSERT INTO Citas (PacienteID, DoctorID, Fecha, Hora, Estado)
    VALUES (@PacienteID, @DoctorID, @Fecha, @Hora, 'Pendiente');
END;

GO;


--SP Actualizar estado cita
CREATE PROCEDURE SP_ActualizarEstadoCita
    @CitaID INT,
    @NuevoEstado NVARCHAR(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Citas WHERE CitaID = @CitaID)
    BEGIN
        RAISERROR('La cita no existe.', 16, 1);
        RETURN;
    END

    UPDATE Citas
    SET Estado = @NuevoEstado
    WHERE CitaID = @CitaID;
END;

GO;


--SP para registro de pago
CREATE PROCEDURE SP_RegistrarPago
    @TratamientoID INT,
    @Monto DECIMAL(10,2),
    @MetodoPago NVARCHAR(50)
AS
BEGIN
    DECLARE @SaldoActual DECIMAL(10,2);

    SELECT @SaldoActual = SaldoPendiente
    FROM Tratamientos
    WHERE TratamientoID = @TratamientoID;

    IF @SaldoActual IS NULL
    BEGIN
        RAISERROR('El tratamiento no existe.', 16, 1);
        RETURN;
    END

    IF @Monto > @SaldoActual
    BEGIN
        RAISERROR('El monto excede el saldo pendiente.', 16, 1);
        RETURN;
    END

    -- Insertar el pago
    INSERT INTO Pagos (TratamientoID, FechaPago, Monto, MetodoPago)
    VALUES (@TratamientoID, GETDATE(), @Monto, @MetodoPago);

    -- Actualizar el saldo pendiente
    UPDATE Tratamientos
    SET SaldoPendiente = SaldoPendiente - @Monto
    WHERE TratamientoID = @TratamientoID;
END;
GO;


--SP para generar los reportes
CREATE PROCEDURE SP_GenerarReporteConsultas
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SELECT D.Nombre AS Doctor, COUNT(C.CitaID) AS TotalCitas,
           SUM(CASE WHEN Estado = 'Completada' THEN 1 ELSE 0 END) AS Completadas,
           SUM(CASE WHEN Estado = 'Cancelada' THEN 1 ELSE 0 END) AS Canceladas
    FROM Citas C
    JOIN Doctores D ON C.DoctorID = D.DoctorID
    WHERE C.Fecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY D.Nombre;
END;
GO;


--SP para notificar la próxima cita
CREATE PROCEDURE SP_NotificarProximaCita
AS
BEGIN
    SELECT C.CitaID, P.Nombre + ' ' + P.Apellido AS Paciente,
           C.Fecha, C.Hora, D.Nombre AS Doctor
    FROM Citas C
    JOIN Pacientes P ON C.PacienteID = P.PacienteID
    JOIN Doctores D ON C.DoctorID = D.DoctorID
    WHERE C.Fecha = CAST(GETDATE() + 1 AS DATE)
      AND C.Estado = 'Pendiente';
END;
