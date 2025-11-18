package metier.service;

import metier.entities.*;
import java.util.List;

public interface IGestionClubService {
    // --- CAS D'UTILISATION : VISITEUR ---
    List<Club> consulterTousLesClubs();
    List<Evenement> consulterTousLesEvenements();
    Utilisateur authentifier(String email, String password);
    Utilisateur creerCompte(Utilisateur u);

    boolean emailExiste(String email);

    // --- CAS D'UTILISATION : ÉTUDIANT ---
    boolean isMembre(int utilisateurId, int clubId);
    void adhererAuClub(int utilisateurId, int clubId);
    void quitterClub(int utilisateurId, int clubId);
    void sInscrireEvenement(int utilisateurId, int evenementId);
    List<MembreClub> consulterMesClubs(int utilisateurId);
    List<Evenement> consulterMesEvenements(int utilisateurId);

    // --- CAS D'UTILISATION : PRÉSIDENT ---
    void creerEvenement(Evenement evt);
    void supprimerEvenement(int evenementId);

    List<MembreClub> voirMembresDuClub(int clubId);
    void supprimerMembreDuClub(int utilisateurId, int clubId);
    void assignRoleToMember(int utilisateurId, int clubId, String roleName);
    boolean estPresidentDuClub(int utilisateurId, int clubId); // Vérification sécurité
    RoleClub isPresident(int utilisateurId); // Vérification sécurité

    // --- CAS D'UTILISATION : ADMIN ---
    void assignerRole(int utilisateurId, String roleName); // Pour gestion des rôles
    void creerClub(Club club);
    void supprimerClub(int clubId);
    void supprimerUtilisateur(int utilisateurId);
}