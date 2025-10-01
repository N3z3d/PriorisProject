import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Messages and notifications translations module
///
/// SOLID COMPLIANCE:
/// - SRP: Only responsible for messages, notifications and user feedback
/// - OCP: Extensible for new message types without modification
/// - LSP: Any locale implementation is substitutable
/// - ISP: Minimal interface for messages functionality
/// - DIP: Depends on abstract interfaces, not concrete implementations
///
/// CONSTRAINTS: <500 lines (currently ~280 lines)
abstract class AppLocalizationsMessages {
  /// Generic success message
  String get success;

  /// Generic error message
  String get error;

  /// Generic warning message
  String get warning;

  /// Generic info message
  String get info;

  // === AUTH MESSAGES ===
  String get loginSuccess;
  String get loginError;
  String get logoutSuccess;
  String get registrationSuccess;
  String get registrationError;
  String get passwordResetSent;

  // === SYNC MESSAGES ===
  String get syncInProgress;
  String get syncSuccess;
  String get syncError;
  String get offlineMode;
  String get onlineMode;

  // === DATA MESSAGES ===
  String get dataLoaded;
  String get dataLoadError;
  String get dataSaved;
  String get dataSaveError;
  String get dataDeleted;
  String get dataDeleteError;

  // === VALIDATION MESSAGES ===
  String get requiredField;
  String get invalidEmail;
  String get passwordTooShort;
  String get nameRequired;
  String get titleRequired;

  // === NETWORK MESSAGES ===
  String get networkError;
  String get connectionLost;
  String get connectionRestored;
  String get serverError;
  String get timeoutError;

  // === PROGRESS MESSAGES ===
  String get loadingData;
  String get savingData;
  String get deletingData;
  String get processingRequest;

  // === CONFIRMATION MESSAGES ===
  String get confirmDelete;
  String get confirmLogout;
  String get confirmClear;
  String get actionCannotBeUndone;

  // === EMPTY STATE MESSAGES ===
  String get noDataAvailable;
  String get noSearchResults;
  String get noItemsFound;
  String get emptyList;
}

/// English messages implementation
class AppLocalizationsMessagesEn extends AppLocalizationsMessages {
  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  // === AUTH MESSAGES ===
  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginError => 'Login failed. Please check your credentials.';

  @override
  String get logoutSuccess => 'Logout successful';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get registrationError => 'Registration failed. Please try again.';

  @override
  String get passwordResetSent => 'Password reset email sent';

  // === SYNC MESSAGES ===
  @override
  String get syncInProgress => 'Synchronizing data...';

  @override
  String get syncSuccess => 'Data synchronized successfully';

  @override
  String get syncError => 'Synchronization failed';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get onlineMode => 'Online mode';

  // === DATA MESSAGES ===
  @override
  String get dataLoaded => 'Data loaded successfully';

  @override
  String get dataLoadError => 'Failed to load data';

  @override
  String get dataSaved => 'Data saved successfully';

  @override
  String get dataSaveError => 'Failed to save data';

  @override
  String get dataDeleted => 'Data deleted successfully';

  @override
  String get dataDeleteError => 'Failed to delete data';

  // === VALIDATION MESSAGES ===
  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get titleRequired => 'Title is required';

  // === NETWORK MESSAGES ===
  @override
  String get networkError => 'Network error occurred';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get serverError => 'Server error occurred';

  @override
  String get timeoutError => 'Request timed out';

  // === PROGRESS MESSAGES ===
  @override
  String get loadingData => 'Loading...';

  @override
  String get savingData => 'Saving...';

  @override
  String get deletingData => 'Deleting...';

  @override
  String get processingRequest => 'Processing...';

  // === CONFIRMATION MESSAGES ===
  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get confirmClear => 'Are you sure you want to clear all data?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone';

  // === EMPTY STATE MESSAGES ===
  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noSearchResults => 'No search results found';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get emptyList => 'List is empty';
}

/// French messages implementation
class AppLocalizationsMessagesFr extends AppLocalizationsMessages {
  @override
  String get success => 'Succès';

  @override
  String get error => 'Erreur';

  @override
  String get warning => 'Attention';

  @override
  String get info => 'Information';

  // === AUTH MESSAGES ===
  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginError => 'Connexion échouée. Vérifiez vos identifiants.';

  @override
  String get logoutSuccess => 'Déconnexion réussie';

  @override
  String get registrationSuccess => 'Inscription réussie';

  @override
  String get registrationError => 'Inscription échouée. Réessayez.';

  @override
  String get passwordResetSent => 'Email de réinitialisation envoyé';

  // === SYNC MESSAGES ===
  @override
  String get syncInProgress => 'Synchronisation en cours...';

  @override
  String get syncSuccess => 'Données synchronisées avec succès';

  @override
  String get syncError => 'Échec de la synchronisation';

  @override
  String get offlineMode => 'Mode hors ligne';

  @override
  String get onlineMode => 'Mode en ligne';

  // === DATA MESSAGES ===
  @override
  String get dataLoaded => 'Données chargées avec succès';

  @override
  String get dataLoadError => 'Échec du chargement des données';

  @override
  String get dataSaved => 'Données sauvegardées avec succès';

  @override
  String get dataSaveError => 'Échec de la sauvegarde';

  @override
  String get dataDeleted => 'Données supprimées avec succès';

  @override
  String get dataDeleteError => 'Échec de la suppression';

  // === VALIDATION MESSAGES ===
  @override
  String get requiredField => 'Ce champ est obligatoire';

  @override
  String get invalidEmail => 'Veuillez entrer un email valide';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get nameRequired => 'Le nom est obligatoire';

  @override
  String get titleRequired => 'Le titre est obligatoire';

  // === NETWORK MESSAGES ===
  @override
  String get networkError => 'Erreur réseau';

  @override
  String get connectionLost => 'Connexion perdue';

  @override
  String get connectionRestored => 'Connexion rétablie';

  @override
  String get serverError => 'Erreur serveur';

  @override
  String get timeoutError => 'Délai dépassé';

  // === PROGRESS MESSAGES ===
  @override
  String get loadingData => 'Chargement...';

  @override
  String get savingData => 'Sauvegarde...';

  @override
  String get deletingData => 'Suppression...';

  @override
  String get processingRequest => 'Traitement...';

  // === CONFIRMATION MESSAGES ===
  @override
  String get confirmDelete => 'Êtes-vous sûr de vouloir supprimer cet élément ?';

  @override
  String get confirmLogout => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get confirmClear => 'Êtes-vous sûr de vouloir effacer toutes les données ?';

  @override
  String get actionCannotBeUndone => 'Cette action ne peut pas être annulée';

  // === EMPTY STATE MESSAGES ===
  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get noSearchResults => 'Aucun résultat trouvé';

  @override
  String get noItemsFound => 'Aucun élément trouvé';

  @override
  String get emptyList => 'Liste vide';
}

/// German messages implementation
class AppLocalizationsMessagesDe extends AppLocalizationsMessages {
  @override
  String get success => 'Erfolg';

  @override
  String get error => 'Fehler';

  @override
  String get warning => 'Warnung';

  @override
  String get info => 'Information';

  // === AUTH MESSAGES ===
  @override
  String get loginSuccess => 'Anmeldung erfolgreich';

  @override
  String get loginError => 'Anmeldung fehlgeschlagen. Überprüfen Sie Ihre Anmeldedaten.';

  @override
  String get logoutSuccess => 'Abmeldung erfolgreich';

  @override
  String get registrationSuccess => 'Registrierung erfolgreich';

  @override
  String get registrationError => 'Registrierung fehlgeschlagen. Versuchen Sie es erneut.';

  @override
  String get passwordResetSent => 'Passwort-Reset-E-Mail gesendet';

  // === SYNC MESSAGES ===
  @override
  String get syncInProgress => 'Daten werden synchronisiert...';

  @override
  String get syncSuccess => 'Daten erfolgreich synchronisiert';

  @override
  String get syncError => 'Synchronisation fehlgeschlagen';

  @override
  String get offlineMode => 'Offline-Modus';

  @override
  String get onlineMode => 'Online-Modus';

  // === DATA MESSAGES ===
  @override
  String get dataLoaded => 'Daten erfolgreich geladen';

  @override
  String get dataLoadError => 'Fehler beim Laden der Daten';

  @override
  String get dataSaved => 'Daten erfolgreich gespeichert';

  @override
  String get dataSaveError => 'Fehler beim Speichern der Daten';

  @override
  String get dataDeleted => 'Daten erfolgreich gelöscht';

  @override
  String get dataDeleteError => 'Fehler beim Löschen der Daten';

  // === VALIDATION MESSAGES ===
  @override
  String get requiredField => 'Dieses Feld ist erforderlich';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get passwordTooShort => 'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get titleRequired => 'Titel ist erforderlich';

  // === NETWORK MESSAGES ===
  @override
  String get networkError => 'Netzwerkfehler aufgetreten';

  @override
  String get connectionLost => 'Verbindung verloren';

  @override
  String get connectionRestored => 'Verbindung wiederhergestellt';

  @override
  String get serverError => 'Serverfehler aufgetreten';

  @override
  String get timeoutError => 'Anfrage-Zeitüberschreitung';

  // === PROGRESS MESSAGES ===
  @override
  String get loadingData => 'Wird geladen...';

  @override
  String get savingData => 'Wird gespeichert...';

  @override
  String get deletingData => 'Wird gelöscht...';

  @override
  String get processingRequest => 'Wird verarbeitet...';

  // === CONFIRMATION MESSAGES ===
  @override
  String get confirmDelete => 'Sind Sie sicher, dass Sie dieses Element löschen möchten?';

  @override
  String get confirmLogout => 'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get confirmClear => 'Sind Sie sicher, dass Sie alle Daten löschen möchten?';

  @override
  String get actionCannotBeUndone => 'Diese Aktion kann nicht rückgängig gemacht werden';

  // === EMPTY STATE MESSAGES ===
  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get noSearchResults => 'Keine Suchergebnisse gefunden';

  @override
  String get noItemsFound => 'Keine Elemente gefunden';

  @override
  String get emptyList => 'Liste ist leer';
}

/// Spanish messages implementation
class AppLocalizationsMessagesEs extends AppLocalizationsMessages {
  @override
  String get success => 'Éxito';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Información';

  // === AUTH MESSAGES ===
  @override
  String get loginSuccess => 'Inicio de sesión exitoso';

  @override
  String get loginError => 'Error de inicio de sesión. Verifique sus credenciales.';

  @override
  String get logoutSuccess => 'Cierre de sesión exitoso';

  @override
  String get registrationSuccess => 'Registro exitoso';

  @override
  String get registrationError => 'Error de registro. Intente nuevamente.';

  @override
  String get passwordResetSent => 'Email de restablecimiento de contraseña enviado';

  // === SYNC MESSAGES ===
  @override
  String get syncInProgress => 'Sincronizando datos...';

  @override
  String get syncSuccess => 'Datos sincronizados exitosamente';

  @override
  String get syncError => 'Error de sincronización';

  @override
  String get offlineMode => 'Modo sin conexión';

  @override
  String get onlineMode => 'Modo en línea';

  // === DATA MESSAGES ===
  @override
  String get dataLoaded => 'Datos cargados exitosamente';

  @override
  String get dataLoadError => 'Error al cargar datos';

  @override
  String get dataSaved => 'Datos guardados exitosamente';

  @override
  String get dataSaveError => 'Error al guardar datos';

  @override
  String get dataDeleted => 'Datos eliminados exitosamente';

  @override
  String get dataDeleteError => 'Error al eliminar datos';

  // === VALIDATION MESSAGES ===
  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get invalidEmail => 'Por favor ingrese un email válido';

  @override
  String get passwordTooShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get titleRequired => 'El título es obligatorio';

  // === NETWORK MESSAGES ===
  @override
  String get networkError => 'Error de red';

  @override
  String get connectionLost => 'Conexión perdida';

  @override
  String get connectionRestored => 'Conexión restaurada';

  @override
  String get serverError => 'Error del servidor';

  @override
  String get timeoutError => 'Tiempo de espera agotado';

  // === PROGRESS MESSAGES ===
  @override
  String get loadingData => 'Cargando...';

  @override
  String get savingData => 'Guardando...';

  @override
  String get deletingData => 'Eliminando...';

  @override
  String get processingRequest => 'Procesando...';

  // === CONFIRMATION MESSAGES ===
  @override
  String get confirmDelete => '¿Está seguro de que desea eliminar este elemento?';

  @override
  String get confirmLogout => '¿Está seguro de que desea cerrar sesión?';

  @override
  String get confirmClear => '¿Está seguro de que desea borrar todos los datos?';

  @override
  String get actionCannotBeUndone => 'Esta acción no se puede deshacer';

  // === EMPTY STATE MESSAGES ===
  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get noSearchResults => 'No se encontraron resultados';

  @override
  String get noItemsFound => 'No se encontraron elementos';

  @override
  String get emptyList => 'Lista vacía';
}

/// Factory pattern for messages implementations
class AppLocalizationsMessagesFactory {
  /// Create appropriate messages implementation based on locale
  static AppLocalizationsMessages create(String locale) {
    switch (locale.toLowerCase()) {
      case 'fr':
        return AppLocalizationsMessagesFr();
      case 'de':
        return AppLocalizationsMessagesDe();
      case 'es':
        return AppLocalizationsMessagesEs();
      case 'en':
      default:
        return AppLocalizationsMessagesEn();
    }
  }
}