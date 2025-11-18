package metier.entities;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(
        name = "membres_club",
        // Contrainte PRO : Un utilisateur ne peut faire qu'UNE seule demande
        // pour un rôle spécifique, qu'elle soit active ou en attente.
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"utilisateur_id", "role_club_id"})
        }
)
public class MembreClub {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne
    @JoinColumn(name = "role_club_id", nullable = false)
    private RoleClub roleClub;

    // ATTRIBUTS DE GESTION DE LA DEMANDE

    /** Statut de la demande : 'EN_ATTENTE', 'ACTIF', 'REFUSE' */
    @Column(name = "statut", length = 20, nullable = false)
    private String statut;

    /** Date à laquelle l'étudiant a cliqué sur "Adhérer" */
    @Temporal(TemporalType.DATE)
    @Column(name = "date_demande", nullable = false)
    private Date dateDemande;

    /** Date à laquelle la demande a été traitée (Acceptée/Refusée) */
    @Temporal(TemporalType.DATE)
    @Column(name = "date_traitement")
    private Date dateTraitement;


    public MembreClub() {}

    // Constructeur simplifié (seul le statut et la date de demande sont essentiels à la création)
    public MembreClub(Utilisateur utilisateur, RoleClub roleClub, Date dateDemande, String statut) {
        this.utilisateur = utilisateur;
        this.roleClub = roleClub;
        this.dateDemande = dateDemande;
        this.statut = statut;
    }

    // --- Getters et Setters (Complétés) ---

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Utilisateur getUtilisateur() { return utilisateur; }
    public void setUtilisateur(Utilisateur utilisateur) { this.utilisateur = utilisateur; }
    public RoleClub getRoleClub() { return roleClub; }
    public void setRoleClub(RoleClub roleClub) { this.roleClub = roleClub; }

    // NOUVEAUX GETTERS/SETTERS
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public Date getDateDemande() { return dateDemande; }
    public void setDateDemande(Date dateDemande) { this.dateDemande = dateDemande; }
    public Date getDateTraitement() { return dateTraitement; }
    public void setDateTraitement(Date dateTraitement) { this.dateTraitement = dateTraitement; }
}