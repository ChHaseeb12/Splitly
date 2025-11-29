import 'app_localizations.dart';

/// Spanish translations
class AppLocalizationsEs extends AppLocalizations {
  // Common
  @override
  String get appName => 'Splitly';
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Cancelar';
  @override
  String get save => 'Guardar';
  @override
  String get delete => 'Eliminar';
  @override
  String get edit => 'Editar';
  @override
  String get add => 'Agregar';
  @override
  String get search => 'Buscar';
  @override
  String get loading => 'Cargando...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Éxito';
  @override
  String get retry => 'Reintentar';
  @override
  String get close => 'Cerrar';
  @override
  String get yes => 'Sí';
  @override
  String get no => 'No';

  // Navigation
  @override
  String get dashboard => 'Panel';
  @override
  String get friends => 'Amigos';
  @override
  String get groups => 'Grupos';
  @override
  String get activity => 'Actividad';
  @override
  String get profile => 'Perfil';

  // Authentication
  @override
  String get login => 'Iniciar Sesión';
  @override
  String get register => 'Registrarse';
  @override
  String get logout => 'Cerrar Sesión';
  @override
  String get email => 'Correo Electrónico';
  @override
  String get password => 'Contraseña';
  @override
  String get confirmPassword => 'Confirmar Contraseña';
  @override
  String get forgotPassword => '¿Olvidaste tu Contraseña?';
  @override
  String get resetPassword => 'Restablecer Contraseña';
  @override
  String get signInWithGoogle => 'Iniciar Sesión con Google';
  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';
  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';
  @override
  String get createAccount => 'Crear Cuenta';
  @override
  String get passwordResetSent => 'Correo de restablecimiento enviado';
  @override
  String get loginSuccess => 'Inicio de sesión exitoso';
  @override
  String get registerSuccess => 'Registro exitoso';
  @override
  String get logoutSuccess => 'Cierre de sesión exitoso';

  // Validation
  @override
  String get emailRequired => 'El correo es requerido';
  @override
  String get passwordRequired => 'La contraseña es requerida';
  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';
  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
  @override
  String get invalidEmail => 'Correo electrónico inválido';

  // Profile
  @override
  String get displayName => 'Nombre para Mostrar';
  @override
  String get phoneNumber => 'Número de Teléfono';
  @override
  String get defaultCurrency => 'Moneda Predeterminada';
  @override
  String get defaultLanguage => 'Idioma Predeterminado';
  @override
  String get profilePicture => 'Foto de Perfil';
  @override
  String get editProfile => 'Editar Perfil';
  @override
  String get settings => 'Configuración';
  @override
  String get currencySettings => 'Configuración de Moneda';
  @override
  String get languageSettings => 'Configuración de Idioma';

  // Expenses
  @override
  String get expenses => 'Gastos';
  @override
  String get addExpense => 'Agregar Gasto';
  @override
  String get editExpense => 'Editar Gasto';
  @override
  String get deleteExpense => 'Eliminar Gasto';
  @override
  String get expenseDetails => 'Detalles del Gasto';
  @override
  String get amount => 'Monto';
  @override
  String get description => 'Descripción';
  @override
  String get category => 'Categoría';
  @override
  String get date => 'Fecha';
  @override
  String get paidBy => 'Pagado Por';
  @override
  String get splitType => 'Tipo de División';
  @override
  String get participants => 'Participantes';
  @override
  String get attachReceipt => 'Adjuntar Recibo';
  @override
  String get notes => 'Notas';
  @override
  String get expenseAdded => 'Gasto agregado exitosamente';
  @override
  String get expenseUpdated => 'Gasto actualizado exitosamente';
  @override
  String get expenseDeleted => 'Gasto eliminado exitosamente';

  // Split Types
  @override
  String get equalSplit => 'División Igual';
  @override
  String get unequalSplit => 'División Desigual';
  @override
  String get percentageSplit => 'División por Porcentaje';
  @override
  String get sharesSplit => 'División por Partes';
  @override
  String get splitEqually => 'Dividir Igualmente';
  @override
  String get splitByAmount => 'Dividir por Monto';
  @override
  String get splitByPercentage => 'Dividir por Porcentaje';
  @override
  String get splitByShares => 'Dividir por Partes';

  // Categories
  @override
  String get food => 'Comida';
  @override
  String get entertainment => 'Entretenimiento';
  @override
  String get utilities => 'Servicios';
  @override
  String get transportation => 'Transporte';
  @override
  String get shopping => 'Compras';
  @override
  String get travel => 'Viajes';
  @override
  String get personal => 'Personal';
  @override
  String get health => 'Salud';
  @override
  String get subscription => 'Suscripción';
  @override
  String get other => 'Otro';

  // Balances
  @override
  String get balances => 'Saldos';
  @override
  String get youOwe => 'Debes';
  @override
  String get owesYou => 'Te Deben';
  @override
  String get settleUp => 'Liquidar';
  @override
  String get settled => 'Liquidado';
  @override
  String get simplifyDebts => 'Simplificar Deudas';
  @override
  String get detailedView => 'Vista Detallada';
  @override
  String get simplifiedView => 'Vista Simplificada';
  @override
  String get settlementHistory => 'Historial de Liquidaciones';
  @override
  String get noBalances => 'No hay saldos para mostrar';

  // Friends
  @override
  String get addFriend => 'Agregar Amigo';
  @override
  String get removeFriend => 'Eliminar Amigo';
  @override
  String get friendRequests => 'Solicitudes de Amistad';
  @override
  String get sendRequest => 'Enviar Solicitud';
  @override
  String get acceptRequest => 'Aceptar';
  @override
  String get declineRequest => 'Rechazar';
  @override
  String get pending => 'Pendiente';
  @override
  String get accepted => 'Aceptado';
  @override
  String get blocked => 'Bloqueado';
  @override
  String get noFriends => 'Aún no tienes amigos';
  @override
  String get friendAdded => 'Amigo agregado exitosamente';
  @override
  String get friendRemoved => 'Amigo eliminado exitosamente';
  @override
  String get requestSent => 'Solicitud de amistad enviada';
  @override
  String get requestAccepted => 'Solicitud de amistad aceptada';
  @override
  String get requestDeclined => 'Solicitud de amistad rechazada';

  // Groups
  @override
  String get createGroup => 'Crear Grupo';
  @override
  String get editGroup => 'Editar Grupo';
  @override
  String get deleteGroup => 'Eliminar Grupo';
  @override
  String get leaveGroup => 'Salir del Grupo';
  @override
  String get groupName => 'Nombre del Grupo';
  @override
  String get groupDescription => 'Descripción del Grupo';
  @override
  String get members => 'Miembros';
  @override
  String get addMember => 'Agregar Miembro';
  @override
  String get removeMember => 'Eliminar Miembro';
  @override
  String get admin => 'Administrador';
  @override
  String get member => 'Miembro';
  @override
  String get transferAdmin => 'Transferir Administrador';
  @override
  String get groupSettings => 'Configuración del Grupo';
  @override
  String get noGroups => 'Aún no tienes grupos';
  @override
  String get groupCreated => 'Grupo creado exitosamente';
  @override
  String get groupUpdated => 'Grupo actualizado exitosamente';
  @override
  String get groupDeleted => 'Grupo eliminado exitosamente';
  @override
  String get memberAdded => 'Miembro agregado exitosamente';
  @override
  String get memberRemoved => 'Miembro eliminado exitosamente';

  // Recurring Expenses
  @override
  String get recurringExpenses => 'Gastos Recurrentes';
  @override
  String get createRecurring => 'Crear Recurrente';
  @override
  String get frequency => 'Frecuencia';
  @override
  String get daily => 'Diario';
  @override
  String get weekly => 'Semanal';
  @override
  String get monthly => 'Mensual';
  @override
  String get yearly => 'Anual';
  @override
  String get startDate => 'Fecha de Inicio';
  @override
  String get endDate => 'Fecha de Fin';
  @override
  String get nextDue => 'Próximo Vencimiento';
  @override
  String get pause => 'Pausar';
  @override
  String get resume => 'Reanudar';
  @override
  String get active => 'Activo';
  @override
  String get paused => 'Pausado';
  @override
  String get upcomingExpenses => 'Próximos Gastos';

  // Saved Splits
  @override
  String get savedSplits => 'Divisiones Guardadas';
  @override
  String get createSavedSplit => 'Crear División Guardada';
  @override
  String get splitName => 'Nombre de la División';
  @override
  String get applySplit => 'Aplicar División';
  @override
  String get noSavedSplits => 'Aún no tienes divisiones guardadas';

  // Currency
  @override
  String get currency => 'Moneda';
  @override
  String get exchangeRate => 'Tipo de Cambio';
  @override
  String get convertedAmount => 'Monto Convertido';
  @override
  String get lastUpdated => 'Última Actualización';
  @override
  String get refreshRates => 'Actualizar Tasas';
  @override
  String get clearCache => 'Limpiar Caché';
  @override
  String get supportedCurrencies => 'Monedas Soportadas';
  @override
  String get popularCurrencies => 'Monedas Populares';
  @override
  String get allCurrencies => 'Todas las Monedas';

  // Language
  @override
  String get language => 'Idioma';
  @override
  String get selectLanguage => 'Seleccionar Idioma';
  @override
  String get languageChanged => 'Idioma cambiado exitosamente';

  // Date & Time
  @override
  String get today => 'Hoy';
  @override
  String get yesterday => 'Ayer';
  @override
  String get tomorrow => 'Mañana';
  @override
  String get thisWeek => 'Esta Semana';
  @override
  String get thisMonth => 'Este Mes';
  @override
  String get thisYear => 'Este Año';

  // Errors
  @override
  String get errorOccurred => 'Ocurrió un error';
  @override
  String get networkError => 'Error de red. Por favor verifica tu conexión.';
  @override
  String get authError => 'Error de autenticación';
  @override
  String get permissionDenied => 'Permiso denegado';
  @override
  String get notFound => 'No encontrado';
  @override
  String get tryAgain => 'Intentar de nuevo';

  // Empty States
  @override
  String get noExpenses => 'Aún no hay gastos';
  @override
  String get noActivity => 'Aún no hay actividad';
  @override
  String get noResults => 'No se encontraron resultados';

  // Filters
  @override
  String get filterBy => 'Filtrar Por';
  @override
  String get dateRange => 'Rango de Fechas';
  @override
  String get allCategories => 'Todas las Categorías';
  @override
  String get allMembers => 'Todos los Miembros';

  // Notifications
  @override
  String get notifications => 'Notificaciones';
  @override
  String get newExpense => 'Nuevo Gasto';
  @override
  String get newFriendRequest => 'Nueva Solicitud de Amistad';
  @override
  String get paymentReceived => 'Pago Recibido';

  // Misc
  @override
  String get total => 'Total';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get perPerson => 'Por Persona';
  @override
  String get share => 'Parte';
  @override
  String get percentage => 'Porcentaje';
  @override
  String get shares => 'Partes';
  @override
  String get viewDetails => 'Ver Detalles';
  @override
  String get confirm => 'Confirmar';
  @override
  String get back => 'Atrás';
}
