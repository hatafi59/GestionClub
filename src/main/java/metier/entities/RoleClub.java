package metier.entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "roles_club")
public class RoleClub {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int roleClubID;

    private String nomRole;

    @ManyToOne
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @OneToMany(mappedBy = "roleClub")
    private List<MembreClub> membresAvecCeRole;

    public RoleClub() {}

    // Getters et Setters
    public int getRoleClubID() { return roleClubID; }
    public void setRoleClubID(int roleClubID) { this.roleClubID = roleClubID; }
    public String getNomRole() { return nomRole; }
    public void setNomRole(String nomRole) { this.nomRole = nomRole; }
    public Club getClub() { return club; }
    public void setClub(Club club) { this.club = club; }
}