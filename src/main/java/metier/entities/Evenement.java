package metier.entities;

import jakarta.persistence.*;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "evenements")
public class Evenement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int evenementID;

    private String titre;
    private String typeEvenement;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Temporal(TemporalType.TIMESTAMP)
    private Date dateEvenement;

    @ManyToOne
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @OneToMany(mappedBy = "evenement", cascade = CascadeType.ALL)
    private List<ParticipantEvenement> participants;

    public Evenement() {}

    // Getters et Setters
    public int getEvenementID() { return evenementID; }
    public void setEvenementID(int evenementID) { this.evenementID = evenementID; }
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    public String getTypeEvenement() { return typeEvenement; }
    public void setTypeEvenement(String typeEvenement) { this.typeEvenement = typeEvenement; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Date getDateEvenement() { return dateEvenement; }
    public void setDateEvenement(Date dateEvenement) { this.dateEvenement = dateEvenement; }
    public Club getClub() { return club; }
    public void setClub(Club club) { this.club = club; }
}