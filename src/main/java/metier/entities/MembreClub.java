package metier.entities;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(
        name = "membres_club",
        // Règle PRO : On empêche d'assigner deux fois le même rôle au même étudiant
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"utilisateur_id", "role_club_id"})
        }
)
public class MembreClub {

    // ID Technique (Surrogate Key) -> Remplace la classe Id composite
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne
    @JoinColumn(name = "role_club_id", nullable = false)
    private RoleClub roleClub;

    @Temporal(TemporalType.DATE)
    private Date dateAdhesion;

    public MembreClub() {}

    public MembreClub(Utilisateur utilisateur, RoleClub roleClub, Date dateAdhesion) {
        this.utilisateur = utilisateur;
        this.roleClub = roleClub;
        this.dateAdhesion = dateAdhesion;
    }

    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Utilisateur getUtilisateur() { return utilisateur; }
    public void setUtilisateur(Utilisateur utilisateur) { this.utilisateur = utilisateur; }
    public RoleClub getRoleClub() { return roleClub; }
    public void setRoleClub(RoleClub roleClub) { this.roleClub = roleClub; }
    public Date getDateAdhesion() { return dateAdhesion; }
    public void setDateAdhesion(Date dateAdhesion) { this.dateAdhesion = dateAdhesion; }
}