package metier.entities;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(
        name = "participants_evenement",
        // Règle PRO : Un utilisateur ne peut pas s'inscrire deux fois au même événement
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"utilisateur_id", "evenement_id"})
        }
)
public class ParticipantEvenement {

    // ID Technique (Surrogate Key)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur participant;

    @ManyToOne
    @JoinColumn(name = "evenement_id", nullable = false)
    private Evenement evenement;

    @Temporal(TemporalType.DATE)
    private Date dateInscription;

    private boolean present;

    public ParticipantEvenement() {}

    public ParticipantEvenement(Utilisateur participant, Evenement evenement) {
        this.participant = participant;
        this.evenement = evenement;
        this.dateInscription = new Date(); // Date du jour par défaut
        this.present = false;
    }

    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Utilisateur getParticipant() { return participant; }
    public void setParticipant(Utilisateur participant) { this.participant = participant; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public Date getDateInscription() { return dateInscription; }
    public void setDateInscription(Date dateInscription) { this.dateInscription = dateInscription; }
    public boolean isPresent() { return present; }
    public void setPresent(boolean present) { this.present = present; }
}