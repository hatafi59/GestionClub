package metier.service.impl;

import dao.*;
import dao.impl.*;
import metier.entities.*;
import metier.service.IGestionClubService;
import org.hibernate.Session;
import org.mindrot.jbcrypt.BCrypt;

import java.util.Date;
import java.util.List;

public class GestionClubServiceImpl implements IGestionClubService {

    // Instanciation des DAOs (Couplage fort ici pour simplifier sans Spring)
    private IClubDao clubDao = new ClubDaoImpl();
    private IEvenementDao eventDao = new EvenementDaoImpl();
    private IUtilisateurDao utilisateurDao = new UtilisateurDaoImpl();
    private IMembreClubDao membreDao = new MembreClubDaoImpl();
    private IRoleClubDao roleClubDao = new RoleClubDaoImpl();
    private IParticipantEvenementDao participantDao = new ParticipantEvenementDaoImpl();
    private IRoleDao roleDao = new RoleDaoImpl();

    @Override
    public List<Club> consulterTousLesClubs() {
        return clubDao.findAll();
    }

    @Override
    public List<Evenement> consulterTousLesEvenements() {
        return eventDao.findAll();
    }

    @Override
    public Utilisateur authentifier(String email, String password) {
        Utilisateur user = utilisateurDao.findByEmail(email);
        if (user != null && BCrypt.checkpw(password, user.getMotDePasseHash())) {
            return user;
        }
        return null;
    }
    @Override
    public Utilisateur creerCompte(Utilisateur u) {
        return utilisateurDao.save(u);
    }
    @Override
    public boolean emailExiste(String email) {
        Utilisateur user = utilisateurDao.findByEmail(email);
        return user != null;
    }

    @Override
    public boolean isMembre(int utilisateurId, int clubId) {
        List<MembreClub> membres = membreDao.findByUtilisateur(utilisateurId);
        for(MembreClub mc : membres) {
            if(mc.getRoleClub().getClub().getClubID() == clubId && mc.getStatut().equals("ACCEPTE")) {
                return true;
            }
        }
        return false;
    }


    @Override
    public String obtenirStatutAdhesion(int utilisateurId, int clubId) {
        List<MembreClub> membres = membreDao.findByUtilisateur(utilisateurId);
        for(MembreClub mc : membres) {
            if(mc.getRoleClub().getClub().getClubID() == clubId) {
                // Un utilisateur ne peut avoir qu'un seul statut par club
                return mc.getStatut();
            }
        }
        // Retour d'une valeur qui n'est pas un statut réel
        return "NON_MEMBRE";
    }
    @Override
    public void adhererAuClub(int utilisateurId, int clubId) {
        // 1. VÉRIFICATION: Membre Actif (ACCEPTE)
        if (isMembre(utilisateurId, clubId)) {
            System.out.println("Vous etes deja membre ACTIF du club");
            return ;
        }

        // 2. VÉRIFICATION: Demande en cours (EN_ATTENTE)
        String statutActuel = obtenirStatutAdhesion(utilisateurId, clubId);

        if ("EN_ATTENTE".equalsIgnoreCase(statutActuel)) {
            System.out.println("Votre demande est déjà EN ATTENTE de validation.");
            return;
        }
        // Si statutActuel est "REFUSE" ou "NON_MEMBRE" (nouveau statut) ou "NON_TROUVE", le processus continue.

        // 3. RECUPERATION DES ENTITÉS
        Utilisateur u = utilisateurDao.findById(utilisateurId);
        Club c = clubDao.findById(clubId);

        // 4. CRÉATION DU RÔLE SI MANQUANT
        RoleClub roleMembre = roleClubDao.findByNomAndClub("MEMBRE", clubId);

        if (roleMembre == null) {
            // CORRECTION 2 : Le rôle créé doit s'appeler "MEMBRE" (c'est le RÔLE),
            // et non "NOT_MEMBRE_YET" (qui est un STATUT/valeur par défaut).
            roleMembre = new RoleClub();
            roleMembre.setNomRole("MEMBRE");
            roleMembre.setClub(c);
            roleClubDao.save(roleMembre);
        }

        // 5. CRÉATION DE L'ADHÉSION
        MembreClub mc = new MembreClub();
        mc.setUtilisateur(u);
        mc.setRoleClub(roleMembre);
        mc.setDateDemande(new Date());
        mc.setStatut("EN_ATTENTE"); // L'utilisateur est défini comme demandeur
        membreDao.save(mc);
    }

    @Override
    public void accepterDemandeAdhesion(int membreClubId) {
        MembreClub mc = membreDao.findById(membreClubId);
        if(mc != null && mc.getStatut().equals("EN_ATTENTE")) {
            mc.setStatut("ACCEPTE");
            mc.setDateTraitement(new Date());
            membreDao.update(mc);
        }
    }
    @Override
    public void refuserDemandeAdhesion(int membreClubId) {
        MembreClub mc = membreDao.findById(membreClubId);
        if(mc != null && mc.getStatut().equals("EN_ATTENTE")) {
            mc.setStatut("REFUSE");
            mc.setDateTraitement(new Date());
            membreDao.update(mc);
        }
    }






    @Override
    public void quitterClub(int utilisateurId, int clubId) {
        // Logique pour trouver l'ID de l'adhésion et supprimer
        boolean dejaMembre = isMembre(utilisateurId, clubId);
        if(!dejaMembre) {
            System.out.println("Vous n'etes pas membre du club");
            return ;
        }

        List<MembreClub> membres = membreDao.findByUtilisateur(utilisateurId);
        for(MembreClub mc : membres) {
            if(mc.getRoleClub().getClub().getClubID() == clubId) {
                membreDao.delete(mc.getId());
                break;
            }
        }

    }

    @Override
    public void sInscrireEvenement(int utilisateurId, int evenementId) {
        if(!participantDao.isParticipant(utilisateurId, evenementId)) {
            Utilisateur u = utilisateurDao.findById(utilisateurId);
            Evenement e = eventDao.findById(evenementId);
            ParticipantEvenement pe = new ParticipantEvenement(u, e);
            pe.setPresent(false); // Par défaut
            participantDao.save(pe);
        }
    }

    @Override
    public List<MembreClub> consulterMesClubs(int utilisateurId) {
        return membreDao.findByUtilisateur(utilisateurId);
    }

    @Override
    public List<Evenement> consulterMesEvenements(int utilisateurId) {
        return eventDao.findByUser(utilisateurId);
    }

    @Override
    public void creerEvenement(Evenement evt) {
        eventDao.save(evt);
    }
    @Override
    public void supprimerEvenement(int evenementId) {
        eventDao.delete(evenementId);
    }
    @Override
    public List<MembreClub> voirMembresDuClub(int clubId) {
        return membreDao.findByClub(clubId);
    }
    @Override
    public void supprimerMembreDuClub(int utilisateurId, int clubId) {
        List<MembreClub> adhesions = membreDao.findByUtilisateur(utilisateurId);
        for (MembreClub mc : adhesions) {
            if (mc.getRoleClub().getClub().getClubID() == clubId) {
                membreDao.delete(mc.getId());
                break;
            }
        }
    }
    @Override
    public List<Evenement> consulterEvenementsDuClub(int clubId) {
        return eventDao.findByClub(clubId);
    }

    @Override
    public void assignRoleToMember(int userId, int clubId, String roleName) {

        // 1. On récupère le membre
        MembreClub targetMember = membreDao.findByUserAndClub(userId, clubId);
        if (targetMember != null) {
            // 2. On cherche si le rôle existe déjà
            RoleClub roleToAssign = roleClubDao.findByNomAndClub(roleName, clubId);
            if (roleToAssign == null) {
                System.out.println("Le rôle '" + roleName + "' n'existe pas. Création en cours...");

                // A. On doit récupérer l'objet Club complet (Hibernate a besoin de l'objet, pas juste de l'ID)
                Club club = clubDao.findById(clubId);

                if (club != null) {
                    // B. On instancie le nouveau rôle
                    roleToAssign = new RoleClub();
                    roleToAssign.setNomRole(roleName);
                    roleToAssign.setClub(club);
                    // C. IMPORTANT : On sauvegarde le nouveau rôle en base pour qu'il ait un ID
                    roleClubDao.save(roleToAssign);
                } else {
                    throw new RuntimeException("Impossible de créer le rôle : Club introuvable.");
                }
            }
            // 3. Maintenant que 'roleToAssign' existe (récupéré ou créé), on l'assigne
            targetMember.setRoleClub(roleToAssign);
            membreDao.update(targetMember);
            System.out.println("Succès : Le rôle " + roleName + " a été assigné.");

        }
    }

    @Override
    public boolean estPresidentDuClub(int utilisateurId, int clubId) {
        List<MembreClub> adhesions = membreDao.findByUtilisateur(utilisateurId);
        for (MembreClub mc : adhesions) {
            if (mc.getRoleClub().getClub().getClubID() == clubId
                    && mc.getRoleClub().getNomRole().equalsIgnoreCase("PRESIDENT")) {
                return true;
            }
        }
        return false;
    }
    @Override
    public RoleClub isPresident(int utilisateurId) {
        List<MembreClub> adhesions = membreDao.findByUtilisateur(utilisateurId);
        for (MembreClub mc : adhesions) {
            if (mc.getRoleClub().getNomRole().equalsIgnoreCase("PRESIDENT")) {
                return mc.getRoleClub();
            }
        }
        return null;
    }


    @Override
    public void creerClub(Club club) {
        clubDao.save(club);
        // Créer automatiquement les rôles de base
        RoleClub r1 = new RoleClub(); r1.setNomRole("PRESIDENT"); r1.setClub(club);
        RoleClub r2 = new RoleClub(); r2.setNomRole("MEMBRE"); r2.setClub(club);
        roleClubDao.save(r1);
        roleClubDao.save(r2);
    }
    @Override
    public void supprimerClub(int clubId) {
        clubDao.delete(clubId);
    }

    @Override
    public void supprimerUtilisateur(int utilisateurId) {
        utilisateurDao.delete(utilisateurId);
    }


    @Override
    public void assignerRole(int userId, String roleName) {
        // 1. On utilise les méthodes standards des DAOs
        Utilisateur u = utilisateurDao.findById(userId);
        Role r = roleDao.findByNom(roleName); // Cette méthode existe déjà dans RoleDaoImpl

        if (u != null && r != null) {
            u.getRoles().add(r);
            utilisateurDao.update(u); // Utilise le update générique qui gère la transaction
        }
    }
}