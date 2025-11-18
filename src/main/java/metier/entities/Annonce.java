package metier.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "annonces")
public class Annonce {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int annonceID;

    private String titre;

    @Column(columnDefinition = "TEXT")
    private String contenu;

    @ManyToOne
    @JoinColumn(name = "auteur_id")
    private Utilisateur auteur;

    @ManyToOne
    @JoinColumn(name = "club_cible_id")
    private Club clubCible;

    public Annonce() {}

    // Getters et Setters
    public int getAnnonceID() { return annonceID; }
    public void setAnnonceID(int annonceID) { this.annonceID = annonceID; }
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    public Utilisateur getAuteur() { return auteur; }
    public void setAuteur(Utilisateur auteur) { this.auteur = auteur; }
    public Club getClubCible() { return clubCible; }
    public void setClubCible(Club clubCible) { this.clubCible = clubCible; }
}