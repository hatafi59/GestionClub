package metier.entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "clubs")
public class Club {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int clubID;

    @Column(nullable = false)
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    // Un Club possède des rôles spécifiques (Ex: Président du Club Échecs)
    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL)
    private List<RoleClub> rolesDuClub;

    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL)
    private List<Evenement> evenements;

    @OneToMany(mappedBy = "clubCible")
    private List<Annonce> annonces;

    public Club() {}

    // Getters et Setters
    public int getClubID() { return clubID; }
    public void setClubID(int clubID) { this.clubID = clubID; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public List<RoleClub> getRolesDuClub() { return rolesDuClub; }
    public void setRolesDuClub(List<RoleClub> rolesDuClub) { this.rolesDuClub = rolesDuClub; }
}