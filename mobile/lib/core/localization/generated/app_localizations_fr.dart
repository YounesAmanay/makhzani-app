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
  String get validation_phoneFormat =>
      'Format de telephone marocain invalide (+212XXXXXXXXX)';

  @override
  String get validation_emailFormat => 'Format d\'email invalide';

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
  String get dashboard_allStocked =>
      'Tous les produits sont bien approvisionnes';

  @override
  String dashboard_seeAllItems(int count) {
    return 'Voir les $count articles';
  }

  @override
  String get dashboard_noOrders => 'Aucune commande pour le moment';

  @override
  String get dashboard_seeAllOrders => 'Voir toutes les commandes';

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
  String get products_searchHint => 'Rechercher des produits...';

  @override
  String get products_noResults => 'Aucun produit trouve';

  @override
  String get products_adjustFilters =>
      'Essayez d\'ajuster votre recherche ou vos filtres';

  @override
  String get products_currentStock => 'Stock actuel';

  @override
  String get products_reorderThreshold => 'Seuil de reapprovisionnement';

  @override
  String get products_barcode => 'Code-barres';

  @override
  String get products_unit => 'Unite';

  @override
  String get products_details => 'Details';

  @override
  String get products_adjustStock => 'Ajuster le stock';

  @override
  String get products_stockAdjusted => 'Stock ajuste avec succes';

  @override
  String get products_created => 'Produit cree avec succes';

  @override
  String get products_updated => 'Produit mis a jour avec succes';

  @override
  String get products_deleted => 'Produit supprime avec succes';

  @override
  String get products_deleteConfirm =>
      'Etes-vous sur de vouloir supprimer ce produit ?';

  @override
  String get products_lowStockOnly => 'Stock faible uniquement';

  @override
  String get products_newStock => 'Nouveau stock';

  @override
  String get products_stockNegativeError => 'Le stock ne peut pas etre negatif';

  @override
  String get products_reason => 'Raison (optionnel)';

  @override
  String get products_adjustment => 'Ajustement';

  @override
  String get products_adjustmentHint => '+10 ou -5';

  @override
  String get products_adjustmentHelper =>
      'Utilisez + pour ajouter, - pour retirer';

  @override
  String get products_photos => 'Photos';

  @override
  String get products_addPhoto => 'Ajouter une photo';

  @override
  String get products_deletePhoto => 'Supprimer la photo';

  @override
  String get products_maxPhotos => 'Maximum 5 photos autorisees';

  @override
  String get products_scanBarcode => 'Scanner le code-barres';

  @override
  String get products_scanSubtitle => 'Remplir les details automatiquement';

  @override
  String get products_lookingUp => 'Recherche du produit...';

  @override
  String get products_toggleTorch => 'Activer/desactiver la lampe';

  @override
  String get products_rescan => 'Re-scanner';

  @override
  String get products_notFound => 'Produit introuvable';

  @override
  String get products_notFoundMessage =>
      'Ce code-barres n\'est pas dans notre base de donnees. Vous pouvez saisir les details manuellement.';

  @override
  String get products_enterManually => 'Saisir manuellement';

  @override
  String get products_scanAgain => 'Scanner a nouveau';

  @override
  String products_autoFilled(String source) {
    return 'Donnees de $source';
  }

  @override
  String get products_stockSection => 'Informations de stock';

  @override
  String get products_pricingSection => 'Tarification';

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
  String get suppliers_unknown => 'Fournisseur inconnu';

  @override
  String get suppliers_searchHint => 'Rechercher des fournisseurs...';

  @override
  String get suppliers_noResults => 'Aucun fournisseur trouve';

  @override
  String get suppliers_adjustFilters => 'Essayez d\'ajuster votre recherche';

  @override
  String get suppliers_businessName => 'Nom de l\'entreprise';

  @override
  String suppliers_totalOrders(int count) {
    return '$count commandes';
  }

  @override
  String get suppliers_contactInfo => 'Coordonnees';

  @override
  String get suppliers_relationship => 'Relation';

  @override
  String get suppliers_preferredContact => 'Contact prefere';

  @override
  String get suppliers_paymentTerms => 'Conditions de paiement';

  @override
  String get suppliers_linkedSince => 'Lie depuis';

  @override
  String get suppliers_lastOrder => 'Derniere commande';

  @override
  String get suppliers_recentOrders => 'Commandes recentes';

  @override
  String get suppliers_noOrders => 'Aucune commande avec ce fournisseur';

  @override
  String get suppliers_deleted => 'Fournisseur supprime avec succes';

  @override
  String get suppliers_deleteConfirm =>
      'Etes-vous sur de vouloir supprimer ce fournisseur ?';

  @override
  String get suppliers_deleteBlockedOrders =>
      'Impossible de supprimer un fournisseur avec des commandes';

  @override
  String get suppliers_contactWhatsApp => 'WhatsApp';

  @override
  String get suppliers_contactPhone => 'Telephone';

  @override
  String get suppliers_contactEmail => 'Email';

  @override
  String get suppliers_orderPdf => 'PDF';

  @override
  String get suppliers_orderSent => 'Envoyee';

  @override
  String get suppliers_created => 'Fournisseur ajoute avec succes';

  @override
  String get suppliers_updated => 'Fournisseur mis a jour avec succes';

  @override
  String get suppliers_phoneHelper =>
      'Format : +212XXXXXXXXX (9 chiffres apres +212)';

  @override
  String get suppliers_filterAllCities => 'Toutes les villes';

  @override
  String get suppliers_citySelect => 'Selectionner la ville';

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
  String get profile_editProfile => 'Modifier le profil';

  @override
  String get profile_shopName => 'Nom du magasin';

  @override
  String get profile_address => 'Adresse';

  @override
  String get profile_updated => 'Profil mis a jour avec succes';

  @override
  String get profile_selectRegion => 'Selectionner la region';

  @override
  String get profile_logout => 'Se deconnecter';

  @override
  String get profile_logoutTitle => 'Deconnexion';

  @override
  String get profile_logoutConfirm =>
      'Etes-vous sur de vouloir vous deconnecter ?';

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
  String get common_clear => 'Effacer';

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
  String get common_today => 'Aujourd\'hui';

  @override
  String get common_yesterday => 'Hier';

  @override
  String common_daysAgo(int count) {
    return 'Il y a $count jours';
  }

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
  String get theme_light => 'Mode clair';

  @override
  String get theme_dark => 'Mode sombre';

  @override
  String get language_switchToArabic => 'العربية';

  @override
  String get language_switchToEnglish => 'English';

  @override
  String get nav_dashboard => 'Tableau de bord';

  @override
  String get nav_products => 'Produits';

  @override
  String get nav_suppliers => 'Fournisseurs';

  @override
  String get nav_orders => 'Commandes';

  @override
  String get comingSoon => 'Bientot disponible';

  @override
  String get comingSoon_description =>
      'Cette fonctionnalite est en cours de developpement';

  @override
  String get sort_nameAsc => 'Nom A→Z';

  @override
  String get sort_nameDesc => 'Nom Z→A';

  @override
  String get sort_stockLow => 'Stock : Plus bas d\'abord';

  @override
  String get sort_stockHigh => 'Stock : Plus haut d\'abord';

  @override
  String get sort_priceLow => 'Prix : Plus bas d\'abord';

  @override
  String get sort_priceHigh => 'Prix : Plus haut d\'abord';

  @override
  String get sort_newest => 'Plus recent d\'abord';

  @override
  String products_resultsCount(int count) {
    return '$count produits';
  }

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

  @override
  String get orders => 'Commandes';

  @override
  String get orders_title => 'Commandes d\'achat';

  @override
  String get orders_searchHint => 'Chercher par n° commande ou fournisseur...';

  @override
  String get orders_empty => 'Aucune commande pour le moment';

  @override
  String get orders_emptyDescription =>
      'Creez votre premiere commande d\'achat pour suivre l\'inventaire';

  @override
  String get orders_add => 'Nouvelle commande';

  @override
  String get orders_orderNumber => 'Numero de commande';

  @override
  String get orders_supplier => 'Fournisseur';

  @override
  String get orders_totalItems => 'Total articles';

  @override
  String get orders_totalValue => 'Valeur totale';

  @override
  String get orders_notes => 'Notes';

  @override
  String get orders_status => 'Statut';

  @override
  String get orders_statusDraft => 'Brouillon';

  @override
  String get orders_statusGenerated => 'Pret';

  @override
  String get orders_statusSent => 'Envoye';

  @override
  String get orders_filterSupplier => 'Filtrer par fournisseur';

  @override
  String get orders_filterStatus => 'Filtrer par statut';

  @override
  String get orders_filterAll => 'Toutes les commandes';

  @override
  String get orders_filterAllSuppliers => 'Tous les fournisseurs';

  @override
  String get orders_createdAt => 'Cree le';

  @override
  String get orders_sentAt => 'Envoye le';

  @override
  String get orders_items => 'articles';

  @override
  String get orders_item => 'article';

  @override
  String get orders_createTitle => 'Creer une commande d\'achat';

  @override
  String get orders_selectSupplier => 'Selectionner le fournisseur';

  @override
  String get orders_supplierRequired => 'Le fournisseur est requis';

  @override
  String get orders_products => 'Produits';

  @override
  String get orders_addProduct => 'Ajouter un produit';

  @override
  String get orders_selectProduct => 'Selectionner un produit';

  @override
  String get orders_quantity => 'Quantite';

  @override
  String get orders_unitPrice => 'Prix unitaire';

  @override
  String get orders_itemTotal => 'Total';

  @override
  String get orders_remove => 'Supprimer';

  @override
  String get orders_grandTotal => 'Total general';

  @override
  String get orders_notesOptional => 'Notes (optionnel)';

  @override
  String get orders_notesPlaceholder =>
      'Ajouter des instructions de livraison ou des notes';

  @override
  String get orders_createButton => 'Creer la commande';

  @override
  String get orders_atLeastOneProduct => 'Ajoutez au moins un produit';

  @override
  String get orders_quantityRequired => 'La quantite est requise';

  @override
  String get orders_quantityMin => 'La quantite doit etre superieure a 0';

  @override
  String get orders_priceMin => 'Le prix doit etre 0 ou plus';

  @override
  String get orders_noSuppliersAvailable => 'Aucun fournisseur disponible';

  @override
  String get orders_addSupplierFirst =>
      'Vous devez d\'abord ajouter un fournisseur';

  @override
  String get orders_noProductsAvailable => 'Aucun produit disponible';

  @override
  String get orders_addProductFirst =>
      'Vous devez d\'abord ajouter des produits';

  @override
  String get orders_productAlreadyAdded => 'Ce produit est deja ajoute';

  @override
  String get orders_orderCreated => 'Commande creee avec succes';

  @override
  String get orders_errorSupplierNotFound => 'Fournisseur non trouve';

  @override
  String get orders_errorProductsNotFound =>
      'Un ou plusieurs produits introuvables';

  @override
  String get orders_orderDetails => 'Details de la commande';

  @override
  String get orders_orderNotFound => 'Commande non trouvee';

  @override
  String get orders_totalQuantity => 'Quantite totale';

  @override
  String get orders_generatePdf => 'Generer PDF';

  @override
  String get orders_downloadPdf => 'Telecharger PDF';

  @override
  String get orders_markAsSent => 'Marquer comme envoye';

  @override
  String get orders_pdfGenerated => 'PDF genere avec succes';

  @override
  String get orders_markedAsSent => 'Commande marquee comme envoyee';

  @override
  String get orders_pdfNotAvailable => 'PDF non disponible';

  @override
  String get orders_downloadingPdf => 'Ouverture du PDF...';

  @override
  String get orders_markSentTitle =>
      'Comment la commande a-t-elle ete envoyee?';

  @override
  String get orders_markSentDescription =>
      'Selectionnez la methode utilisee pour envoyer la commande';

  @override
  String get orders_sentViaWhatsApp => 'WhatsApp';

  @override
  String get orders_sentViaEmail => 'Email';

  @override
  String get orders_sentViaPhone => 'Appel telephonique';

  @override
  String get orders_sentViaInPerson => 'En personne';

  @override
  String get orders_sendViaWhatsApp => 'Envoyer par WhatsApp';

  @override
  String get orders_generateAndOpen => 'Generer PDF';

  @override
  String get orders_noWhatsapp => 'WhatsApp n\'est pas installe';

  @override
  String get orders_pdfError =>
      'Echec de generation du PDF. Veuillez reessayer.';

  @override
  String get orders_whatsappSent => 'Commande envoyee via WhatsApp';

  @override
  String get orders_newOrderTitle => 'Nouvelle commande';

  @override
  String get orders_selectSupplierHint => 'Rechercher des fournisseurs...';

  @override
  String get orders_selectSupplierPrompt =>
      'Sélectionnez un fournisseur pour commencer votre commande';

  @override
  String get orders_changeSupplier => 'Changer le fournisseur';

  @override
  String get orders_selectSupplierAction => 'Sélectionner un fournisseur';

  @override
  String get orders_recentSuppliers => 'Recents';

  @override
  String get orders_allSuppliers => 'Tous les fournisseurs';

  @override
  String orders_buildOrderTitle(String supplierName) {
    return 'Commande $supplierName';
  }

  @override
  String get orders_searchProducts => 'Rechercher des produits...';

  @override
  String get orders_addToOrder => 'Ajouter';

  @override
  String orders_addToOrderTotal(String total) {
    return 'Ajouter ($total MAD)';
  }

  @override
  String orders_updateTotal(String total) {
    return 'Mettre a jour ($total MAD)';
  }

  @override
  String get orders_removeFromOrder => 'Retirer de la commande';

  @override
  String get orders_inOrder => 'Dans la commande';

  @override
  String get orders_reviewTitle => 'Verifier la commande';

  @override
  String get orders_saveAsDraft => 'Enregistrer comme brouillon';

  @override
  String get orders_draftSaved => 'Commande enregistree comme brouillon';

  @override
  String get orders_callSupplier => 'Appeler le fournisseur';

  @override
  String orders_itemsSummary(int count, String total) {
    return '$count articles · $total MAD';
  }

  @override
  String get orders_reviewOrder => 'Créer & Vérifier';

  @override
  String get orders_outOfStock => 'En rupture de stock';

  @override
  String orders_stockLabel(int count, String unit) {
    return 'Stock: $count $unit';
  }

  @override
  String common_minutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String common_hoursAgo(int count) {
    return 'il y a ${count}h';
  }

  @override
  String get common_seeAll => 'Voir tout';
}
