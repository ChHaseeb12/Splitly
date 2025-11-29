import 'app_localizations.dart';

/// French translations
class AppLocalizationsFr extends AppLocalizations {
  // Common
  @override
  String get appName => 'Splitly';
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Annuler';
  @override
  String get save => 'Enregistrer';
  @override
  String get delete => 'Supprimer';
  @override
  String get edit => 'Modifier';
  @override
  String get add => 'Ajouter';
  @override
  String get search => 'Rechercher';
  @override
  String get loading => 'Chargement...';
  @override
  String get error => 'Erreur';
  @override
  String get success => 'Succès';
  @override
  String get retry => 'Réessayer';
  @override
  String get close => 'Fermer';
  @override
  String get yes => 'Oui';
  @override
  String get no => 'Non';

  // Navigation
  @override
  String get dashboard => 'Tableau de bord';
  @override
  String get friends => 'Amis';
  @override
  String get groups => 'Groupes';
  @override
  String get activity => 'Activité';
  @override
  String get profile => 'Profil';

  // Authentication
  @override
  String get login => 'Connexion';
  @override
  String get register => "S'inscrire";
  @override
  String get logout => 'Déconnexion';
  @override
  String get email => 'Email';
  @override
  String get password => 'Mot de passe';
  @override
  String get confirmPassword => 'Confirmer le mot de passe';
  @override
  String get forgotPassword => 'Mot de passe oublié?';
  @override
  String get resetPassword => 'Réinitialiser le mot de passe';
  @override
  String get signInWithGoogle => 'Se connecter avec Google';
  @override
  String get dontHaveAccount => "Vous n'avez pas de compte?";
  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';
  @override
  String get createAccount => 'Créer un compte';
  @override
  String get passwordResetSent => 'Email de réinitialisation envoyé';
  @override
  String get loginSuccess => 'Connexion réussie';
  @override
  String get registerSuccess => 'Inscription réussie';
  @override
  String get logoutSuccess => 'Déconnexion réussie';

  // Validation
  @override
  String get emailRequired => "L'email est requis";
  @override
  String get passwordRequired => 'Le mot de passe est requis';
  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';
  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';
  @override
  String get invalidEmail => 'Adresse email invalide';

  // Profile
  @override
  String get displayName => "Nom d'affichage";
  @override
  String get phoneNumber => 'Numéro de téléphone';
  @override
  String get defaultCurrency => 'Devise par défaut';
  @override
  String get defaultLanguage => 'Langue par défaut';
  @override
  String get profilePicture => 'Photo de profil';
  @override
  String get editProfile => 'Modifier le profil';
  @override
  String get settings => 'Paramètres';
  @override
  String get currencySettings => 'Paramètres de devise';
  @override
  String get languageSettings => 'Paramètres de langue';

  // Expenses
  @override
  String get expenses => 'Dépenses';
  @override
  String get addExpense => 'Ajouter une dépense';
  @override
  String get editExpense => 'Modifier la dépense';
  @override
  String get deleteExpense => 'Supprimer la dépense';
  @override
  String get expenseDetails => 'Détails de la dépense';
  @override
  String get amount => 'Montant';
  @override
  String get description => 'Description';
  @override
  String get category => 'Catégorie';
  @override
  String get date => 'Date';
  @override
  String get paidBy => 'Payé par';
  @override
  String get splitType => 'Type de partage';
  @override
  String get participants => 'Participants';
  @override
  String get attachReceipt => 'Joindre un reçu';
  @override
  String get notes => 'Notes';
  @override
  String get expenseAdded => 'Dépense ajoutée avec succès';
  @override
  String get expenseUpdated => 'Dépense mise à jour avec succès';
  @override
  String get expenseDeleted => 'Dépense supprimée avec succès';

  // Split Types
  @override
  String get equalSplit => 'Partage égal';
  @override
  String get unequalSplit => 'Partage inégal';
  @override
  String get percentageSplit => 'Partage en pourcentage';
  @override
  String get sharesSplit => 'Partage en parts';
  @override
  String get splitEqually => 'Partager également';
  @override
  String get splitByAmount => 'Partager par montant';
  @override
  String get splitByPercentage => 'Partager par pourcentage';
  @override
  String get splitByShares => 'Partager par parts';

  // Categories
  @override
  String get food => 'Nourriture';
  @override
  String get entertainment => 'Divertissement';
  @override
  String get utilities => 'Services publics';
  @override
  String get transportation => 'Transport';
  @override
  String get shopping => 'Achats';
  @override
  String get travel => 'Voyage';
  @override
  String get personal => 'Personnel';
  @override
  String get health => 'Santé';
  @override
  String get subscription => 'Abonnement';
  @override
  String get other => 'Autre';

  // Balances
  @override
  String get balances => 'Soldes';
  @override
  String get youOwe => 'Vous devez';
  @override
  String get owesYou => 'Vous est dû';
  @override
  String get settleUp => 'Régler';
  @override
  String get settled => 'Réglé';
  @override
  String get simplifyDebts => 'Simplifier les dettes';
  @override
  String get detailedView => 'Vue détaillée';
  @override
  String get simplifiedView => 'Vue simplifiée';
  @override
  String get settlementHistory => 'Historique des règlements';
  @override
  String get noBalances => 'Aucun solde à afficher';

  // Friends
  @override
  String get addFriend => 'Ajouter un ami';
  @override
  String get removeFriend => 'Supprimer un ami';
  @override
  String get friendRequests => "Demandes d'ami";
  @override
  String get sendRequest => 'Envoyer une demande';
  @override
  String get acceptRequest => 'Accepter';
  @override
  String get declineRequest => 'Refuser';
  @override
  String get pending => 'En attente';
  @override
  String get accepted => 'Accepté';
  @override
  String get blocked => 'Bloqué';
  @override
  String get noFriends => "Pas encore d'amis";
  @override
  String get friendAdded => 'Ami ajouté avec succès';
  @override
  String get friendRemoved => 'Ami supprimé avec succès';
  @override
  String get requestSent => "Demande d'ami envoyée";
  @override
  String get requestAccepted => "Demande d'ami acceptée";
  @override
  String get requestDeclined => "Demande d'ami refusée";

  // Groups
  @override
  String get createGroup => 'Créer un groupe';
  @override
  String get editGroup => 'Modifier le groupe';
  @override
  String get deleteGroup => 'Supprimer le groupe';
  @override
  String get leaveGroup => 'Quitter le groupe';
  @override
  String get groupName => 'Nom du groupe';
  @override
  String get groupDescription => 'Description du groupe';
  @override
  String get members => 'Membres';
  @override
  String get addMember => 'Ajouter un membre';
  @override
  String get removeMember => 'Supprimer un membre';
  @override
  String get admin => 'Administrateur';
  @override
  String get member => 'Membre';
  @override
  String get transferAdmin => "Transférer l'administration";
  @override
  String get groupSettings => 'Paramètres du groupe';
  @override
  String get noGroups => 'Pas encore de groupes';
  @override
  String get groupCreated => 'Groupe créé avec succès';
  @override
  String get groupUpdated => 'Groupe mis à jour avec succès';
  @override
  String get groupDeleted => 'Groupe supprimé avec succès';
  @override
  String get memberAdded => 'Membre ajouté avec succès';
  @override
  String get memberRemoved => 'Membre supprimé avec succès';

  // Recurring Expenses
  @override
  String get recurringExpenses => 'Dépenses récurrentes';
  @override
  String get createRecurring => 'Créer une récurrence';
  @override
  String get frequency => 'Fréquence';
  @override
  String get daily => 'Quotidien';
  @override
  String get weekly => 'Hebdomadaire';
  @override
  String get monthly => 'Mensuel';
  @override
  String get yearly => 'Annuel';
  @override
  String get startDate => 'Date de début';
  @override
  String get endDate => 'Date de fin';
  @override
  String get nextDue => 'Prochaine échéance';
  @override
  String get pause => 'Pause';
  @override
  String get resume => 'Reprendre';
  @override
  String get active => 'Actif';
  @override
  String get paused => 'En pause';
  @override
  String get upcomingExpenses => 'Dépenses à venir';

  // Saved Splits
  @override
  String get savedSplits => 'Partages enregistrés';
  @override
  String get createSavedSplit => 'Créer un partage enregistré';
  @override
  String get splitName => 'Nom du partage';
  @override
  String get applySplit => 'Appliquer le partage';
  @override
  String get noSavedSplits => 'Pas encore de partages enregistrés';

  // Currency
  @override
  String get currency => 'Devise';
  @override
  String get exchangeRate => 'Taux de change';
  @override
  String get convertedAmount => 'Montant converti';
  @override
  String get lastUpdated => 'Dernière mise à jour';
  @override
  String get refreshRates => 'Actualiser les taux';
  @override
  String get clearCache => 'Vider le cache';
  @override
  String get supportedCurrencies => 'Devises prises en charge';
  @override
  String get popularCurrencies => 'Devises populaires';
  @override
  String get allCurrencies => 'Toutes les devises';

  // Language
  @override
  String get language => 'Langue';
  @override
  String get selectLanguage => 'Sélectionner la langue';
  @override
  String get languageChanged => 'Langue modifiée avec succès';

  // Date & Time
  @override
  String get today => "Aujourd'hui";
  @override
  String get yesterday => 'Hier';
  @override
  String get tomorrow => 'Demain';
  @override
  String get thisWeek => 'Cette semaine';
  @override
  String get thisMonth => 'Ce mois-ci';
  @override
  String get thisYear => 'Cette année';

  // Errors
  @override
  String get errorOccurred => "Une erreur s'est produite";
  @override
  String get networkError =>
      'Erreur réseau. Veuillez vérifier votre connexion.';
  @override
  String get authError => "Erreur d'authentification";
  @override
  String get permissionDenied => 'Permission refusée';
  @override
  String get notFound => 'Non trouvé';
  @override
  String get tryAgain => 'Réessayer';

  // Empty States
  @override
  String get noExpenses => 'Pas encore de dépenses';
  @override
  String get noActivity => "Pas encore d'activité";
  @override
  String get noResults => 'Aucun résultat trouvé';

  // Filters
  @override
  String get filterBy => 'Filtrer par';
  @override
  String get dateRange => 'Plage de dates';
  @override
  String get allCategories => 'Toutes les catégories';
  @override
  String get allMembers => 'Tous les membres';

  // Notifications
  @override
  String get notifications => 'Notifications';
  @override
  String get newExpense => 'Nouvelle dépense';
  @override
  String get newFriendRequest => "Nouvelle demande d'ami";
  @override
  String get paymentReceived => 'Paiement reçu';

  // Misc
  @override
  String get total => 'Total';
  @override
  String get subtotal => 'Sous-total';
  @override
  String get perPerson => 'Par personne';
  @override
  String get share => 'Part';
  @override
  String get percentage => 'Pourcentage';
  @override
  String get shares => 'Parts';
  @override
  String get viewDetails => 'Voir les détails';
  @override
  String get confirm => 'Confirmer';
  @override
  String get back => 'Retour';
}
