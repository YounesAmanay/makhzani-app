// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Makhzani';

  @override
  String get auth_phoneInputTitle =>
      'Entrez votre numero de telephone pour continuer';

  @override
  String get auth_phoneLabel => 'Numero de telephone';

  @override
  String get auth_phoneHint => '6XXXXXXXX';

  @override
  String get auth_phonePrefixMorocco => '+212';

  @override
  String get auth_sendCode => 'Envoyer le code';

  @override
  String get auth_verifyTitle => 'Entrez le code de verification';

  @override
  String auth_verifySubtitle(String phoneNumber) {
    return 'Nous avons envoye un code a 4 chiffres a\n$phoneNumber';
  }

  @override
  String get auth_verify => 'Verifier';

  @override
  String get auth_resendCode => 'Renvoyer le code';

  @override
  String get auth_codeResent => 'Code renvoye avec succes';

  @override
  String get auth_invalidCode => 'Code invalide. Veuillez reessayer.';

  @override
  String get auth_failedToSendOtp =>
      'Echec de l\'envoi du code. Veuillez reessayer.';

  @override
  String get validation_required => 'Ce champ est obligatoire';

  @override
  String get validation_phoneLength =>
      'Le numero de telephone doit contenir 9 chiffres';

  @override
  String get validation_phonePrefix =>
      'Le numero de telephone doit commencer par 5, 6 ou 7';

  @override
  String get validation_otpLength => 'Veuillez entrer le code a 4 chiffres';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get dashboard_totalProducts => 'Total des produits';

  @override
  String get dashboard_lowStock => 'Stock faible';

  @override
  String get dashboard_totalSuppliers => 'Fournisseurs';

  @override
  String get dashboard_pendingOrders => 'Commandes en attente';

  @override
  String get dashboard_recentOrders => 'Commandes recentes';

  @override
  String get dashboard_quickActions => 'Actions rapides';

  @override
  String get dashboard_viewAll => 'Voir tout';

  @override
  String get products => 'Produits';

  @override
  String get products_add => 'Ajouter un produit';

  @override
  String get products_edit => 'Modifier le produit';

  @override
  String get products_name => 'Nom du produit';

  @override
  String get products_sku => 'Reference';

  @override
  String get products_price => 'Prix';

  @override
  String get products_costPrice => 'Prix d\'achat';

  @override
  String get products_sellingPrice => 'Prix de vente';

  @override
  String get products_quantity => 'Quantite';

  @override
  String get products_minStock => 'Stock minimum';

  @override
  String get products_category => 'Categorie';

  @override
  String get products_description => 'Description';

  @override
  String get products_inStock => 'En stock';

  @override
  String get products_outOfStock => 'Rupture de stock';

  @override
  String get products_lowStockWarning => 'Stock faible';

  @override
  String get products_empty => 'Aucun produit pour le moment';

  @override
  String get products_emptyDescription =>
      'Ajoutez votre premier produit pour commencer';

  @override
  String get products_searchHint => 'Search products...';

  @override
  String get products_noResults => 'No products found';

  @override
  String get products_adjustFilters => 'Try adjusting your search or filters';

  @override
  String get products_currentStock => 'Current Stock';

  @override
  String get products_reorderThreshold => 'Reorder Threshold';

  @override
  String get products_barcode => 'Barcode';

  @override
  String get products_unit => 'Unit';

  @override
  String get products_details => 'Details';

  @override
  String get products_adjustStock => 'Adjust Stock';

  @override
  String get products_stockAdjusted => 'Stock adjusted successfully';

  @override
  String get products_created => 'Product created successfully';

  @override
  String get products_updated => 'Product updated successfully';

  @override
  String get products_deleted => 'Product deleted successfully';

  @override
  String get products_deleteConfirm =>
      'Are you sure you want to delete this product?';

  @override
  String get products_lowStockOnly => 'Low stock only';

  @override
  String get products_stockAdd => 'Add';

  @override
  String get products_stockRemove => 'Remove';

  @override
  String get products_newStock => 'New stock';

  @override
  String get products_stockNegativeError => 'Stock cannot be negative';

  @override
  String get products_reason => 'Reason (optional)';

  @override
  String get suppliers => 'Fournisseurs';

  @override
  String get suppliers_add => 'Ajouter un fournisseur';

  @override
  String get suppliers_edit => 'Modifier le fournisseur';

  @override
  String get suppliers_name => 'Nom du fournisseur';

  @override
  String get suppliers_phone => 'Telephone';

  @override
  String get suppliers_email => 'Email';

  @override
  String get suppliers_address => 'Adresse';

  @override
  String get suppliers_city => 'Ville';

  @override
  String get suppliers_notes => 'Notes';

  @override
  String get suppliers_empty => 'Aucun fournisseur pour le moment';

  @override
  String get suppliers_emptyDescription =>
      'Ajoutez votre premier fournisseur pour gerer vos achats';

  @override
  String get orders => 'Commandes';

  @override
  String get orders_purchase => 'Bons de commande';

  @override
  String get orders_create => 'Creer une commande';

  @override
  String get orders_edit => 'Modifier la commande';

  @override
  String get orders_supplier => 'Fournisseur';

  @override
  String get orders_selectSupplier => 'Selectionner un fournisseur';

  @override
  String get orders_items => 'Articles';

  @override
  String get orders_addItem => 'Ajouter un article';

  @override
  String get orders_total => 'Total';

  @override
  String get orders_status => 'Statut';

  @override
  String get orders_status_draft => 'Brouillon';

  @override
  String get orders_status_sent => 'Envoyee';

  @override
  String get orders_status_received => 'Recue';

  @override
  String get orders_status_cancelled => 'Annulee';

  @override
  String get orders_markSent => 'Marquer comme envoyee';

  @override
  String get orders_markReceived => 'Marquer comme recue';

  @override
  String get orders_generatePdf => 'Generer PDF';

  @override
  String get orders_downloadPdf => 'Telecharger PDF';

  @override
  String get orders_empty => 'Aucune commande pour le moment';

  @override
  String get orders_emptyDescription => 'Creez votre premier bon de commande';

  @override
  String get profile => 'Profil';

  @override
  String get profile_businessName => 'Nom de l\'entreprise';

  @override
  String get profile_ownerName => 'Nom du proprietaire';

  @override
  String get profile_phone => 'Telephone';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_region => 'Region';

  @override
  String get profile_subscription => 'Abonnement';

  @override
  String profile_trialEnds(String date) {
    return 'Essai se termine le $date';
  }

  @override
  String get settings => 'Parametres';

  @override
  String get settings_language => 'Langue';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_about => 'A propos';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_add => 'Ajouter';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_filter => 'Filtrer';

  @override
  String get common_sort => 'Trier';

  @override
  String get common_refresh => 'Actualiser';

  @override
  String get common_retry => 'Reessayer';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_back => 'Retour';

  @override
  String get common_next => 'Suivant';

  @override
  String get common_done => 'Termine';

  @override
  String get common_skip => 'Ignorer';

  @override
  String get common_moreOptions => 'Plus d\'options';

  @override
  String get common_selectAll => 'Tout selectionner';

  @override
  String get common_clearAll => 'Tout effacer';

  @override
  String get error_generic => 'Une erreur s\'est produite';

  @override
  String get error_network => 'Pas de connexion Internet';

  @override
  String get error_server => 'Erreur serveur. Veuillez reessayer plus tard.';

  @override
  String get error_timeout => 'Delai d\'attente depasse';

  @override
  String get error_unknown => 'Une erreur inconnue s\'est produite';

  @override
  String get success_saved => 'Enregistre avec succes';

  @override
  String get success_deleted => 'Supprime avec succes';

  @override
  String get success_updated => 'Mis a jour avec succes';

  @override
  String get success_created => 'Cree avec succes';

  @override
  String get confirm_delete => 'Etes-vous sur de vouloir supprimer ?';

  @override
  String get confirm_deleteTitle => 'Supprimer';

  @override
  String get confirm_logout => 'Etes-vous sur de vouloir vous deconnecter ?';

  @override
  String get confirm_logoutTitle => 'Deconnexion';

  @override
  String get confirm_discard =>
      'Etes-vous sur de vouloir abandonner les modifications ?';

  @override
  String get confirm_discardTitle => 'Abandonner les modifications';

  @override
  String get logout => 'Deconnexion';

  @override
  String get currency_mad => 'MAD';

  @override
  String itemCount(int count) {
    return '$count articles';
  }

  @override
  String itemCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }
}
