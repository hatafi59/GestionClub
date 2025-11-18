package metier.entities;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "utilisateurs")
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int utilisateurID;

    private String nomUtilisateur;
    private String motDePasseHash;

    @Column(unique = true, nullable = false)
    private String email;

    private String niveauEtude;

    // Relation ManyToMany simple pour les Rôles globaux (Admin, Etudiant)
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "utilisateurs_roles",
            joinColumns = @JoinColumn(name = "utilisateur_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private List<Role> roles = new ArrayList<>();

    // Relations inverses pour naviguer facilement
    @OneToMany(mappedBy = "utilisateur", cascade = CascadeType.ALL)
    private List<MembreClub> adhesions;

    @OneToMany(mappedBy = "participant", cascade = CascadeType.ALL)
    private List<ParticipantEvenement> participations;

    @OneToMany(mappedBy = "auteur")
    private List<Annonce> annonces;

    public Utilisateur() {}

    // Getters et Setters
    public int getUtilisateurID() { return utilisateurID; }
    public void setUtilisateurID(int utilisateurID) { this.utilisateurID = utilisateurID; }
    public String getNomUtilisateur() { return nomUtilisateur; }
    public void setNomUtilisateur(String nomUtilisateur) { this.nomUtilisateur = nomUtilisateur; }
    public String getMotDePasseHash() { return motDePasseHash; }
    public void setMotDePasseHash(String motDePasseHash) { this.motDePasseHash = motDePasseHash; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getNiveauEtude() { return niveauEtude; }
    public void setNiveauEtude(String niveauEtude) { this.niveauEtude = niveauEtude; }
    public List<Role> getRoles() { return roles; }
    public void setRoles(List<Role> roles) { this.roles = roles; }
    public List<MembreClub> getAdhesions() { return adhesions; }
    public void setAdhesions(List<MembreClub> adhesions) { this.adhesions = adhesions; }
}