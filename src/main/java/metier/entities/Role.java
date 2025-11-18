package metier.entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "roles")
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int roleID;

    @Column(unique = true, nullable = false)
    private String nomRole;

    @ManyToMany(mappedBy = "roles")
    private List<Utilisateur> utilisateurs;

    public Role() {}
    public Role(String nomRole) { this.nomRole = nomRole; }

    // Getters et Setters
    public int getRoleID() { return roleID; }
    public void setRoleID(int roleID) { this.roleID = roleID; }
    public String getNomRole() { return nomRole; }
    public void setNomRole(String nomRole) { this.nomRole = nomRole; }
}