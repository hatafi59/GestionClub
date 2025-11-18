<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // On récupère les listes depuis la request (envoyées par le Controller)
    // Si null (accès direct), on tente la session
    List<MembreClub> mesClubs = (List<MembreClub>) request.getAttribute("listMesClubs");
    if (mesClubs == null) mesClubs = (List<MembreClub>) session.getAttribute("mesClubs");
    List<Evenement> mesEvents = (List<Evenement>) request.getAttribute("listMesEvents");
    if (mesEvents == null) mesEvents = (List<Evenement>) session.getAttribute("mesEvents");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Mon Espace - ENSA Clubs</title>
    <style>
        /* (Styles CSS inchangés) */
        :root {
            --primary: #095bca;      /* Bleu principal */
            --secondary: #2172ac;    /* Bleu secondaire */
            --accent: #ff6b6b;       /* Accent rouge/corail */
            --success: #00b894;      /* Vert succès */
            --text-dark: #2d3436;
            --text-light: #636e72;
            --bg-light: #f9f9f9;
            --white: #ffffff;
            --shadow: 0 10px 20px rgba(0,0,0,0.08);
            --radius: 16px;
        }

        body { font-family: system-ui, sans-serif; background: var(--light-bg); margin: 0; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }

        h2, h3 { color: #333; display: inline-block; margin-bottom: 20px; padding-bottom: 5px; }

        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }

        /* Table Styles */
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 40px; }
        .data-table th, .data-table td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        .data-table th { background-color: var(--secondary); color: white; }
        .data-table tr:last-child td { border-bottom: none; }
        .data-table tr:hover { background-color: #f1f1f1; }

        /* Badges pour les rôles */
        .badge { padding: 5px 10px; border-radius: 20px; font-size: 0.85em; font-weight: bold; }
        .badge-role { background-color: #e2e6ea; color: #333; border: 1px solid #ccc;  }
        .badge-president { background-color: #ffc107; color: #000; } /* Or pour président */

        .btn-danger { background-color: var(--accent); color: white; border: none; padding: 8px 12px; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 0.9em; }
        .btn-danger:hover { background-color: #bd2130; }

        .section-title {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            margin-top: 20px;
        }
        .section-title h3 {
            font-size: 1.8rem;
            color: var(--text-dark);
            position: relative;
            padding-left: 15px;
        }
        .section-title h3::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            height: 30px;
            width: 5px;
            background-color: var(--accent);
            border-radius: 5px;
        }
    </style>
</head>
<body>

<jsp:include page="/common/header.jsp" />

<div class="container">
    <% if ("adhesion_ok".equals(msg)) { %> <div class="alert alert-success">Vous avez rejoint le club avec succès !</div> <% } %>
    <% if ("inscription_ok".equals(msg)) { %> <div class="alert alert-success">Inscription à l'événement confirmée !</div> <% } %>
    <% if ("quitter_ok".equals(msg)) { %> <div class="alert alert-success">Vous avez quitté le club.</div> <% } %>

    <div class="section-title">
        <h3>Liste des Clubs</h3>
    </div>
    <% if (mesClubs != null && !mesClubs.isEmpty()) { %>
    <table class="data-table">
        <thead>
        <tr>
            <th>Club</th>
            <th>Date de Demande</th>
            <th>Date de Traitement</th> <th>Status</th>
            <th>Mon Rôle</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% for (MembreClub mc : mesClubs) {
            boolean isPending = "EN_ATTENTE".equalsIgnoreCase(mc.getStatut());
            String buttonText = isPending ? "Annuler" : "Quitter";
        %>
        <tr>
            <td><strong><%= mc.getRoleClub().getClub().getNom() %></strong></td>

            <%-- Date de Demande (Toujours définie) --%>
            <td><%= mc.getDateDemande() != null ? sdf.format(mc.getDateDemande()) : "N/A" %></td>

            <%-- Date de Traitement (CORRECTION POUR GÉRER NULL) --%>
            <td>
                <%-- Si la date de traitement est NULL, on affiche "En attente" ou "N/A" --%>
                <%= mc.getDateTraitement() != null ? sdf.format(mc.getDateTraitement()) : "En attente de reponse" %>
            </td>

            <td><%=mc.getStatut()%></td>
            <td>
                <%
                    String roleName = mc.getRoleClub().getNomRole();
                    String badgeClass = "PRESIDENT".equalsIgnoreCase(roleName) ? "badge-president" : "badge-role";
                %>
                <span class="badge <%= badgeClass %>"><%= roleName %></span>
            </td>
            <td>
                <% if (!"PRESIDENT".equalsIgnoreCase(roleName)) { %>
                <form action="${pageContext.request.contextPath}/etudiant?action=quitterClub" method="post" onsubmit="return confirm('Voulez-vous vraiment quitter ce club ?');">
                    <input type="hidden" name="action" value="quitterClub">
                    <input type="hidden" name="clubId" value="<%= mc.getRoleClub().getClub().getClubID() %>">
                    <button type="submit" class="btn-danger">
                        <%= buttonText %>
                    </button>
                </form>
                <% } else if ("REFUSE".equalsIgnoreCase(mc.getStatut())) { %>
                <small class="text-muted" style="color:var(--accent);">Demande refusée</small>
                <% } else { %>
                <small class="text-muted">Président (Gestion via Bureau)</small>
                <% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    <% } else { %>
    <p>Vous n'êtes membre d'aucun club pour le moment.</p>
    <% } %>

    <div class="section-title">
        <h3>Liste des Événements</h3>
    </div>
    <% if (mesEvents != null && !mesEvents.isEmpty()) { %>
    <div class="grid-container" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
        <% for (Evenement evt : mesEvents) { %>
        <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <h4 style="margin-top:0; color: var(--primary-color);"><%= evt.getTitre() %></h4>
            <p><strong>Date :</strong> <%= sdf.format(evt.getDateEvenement()) %></p>
            <p><strong>Lieu/Club :</strong> <%= evt.getClub().getNom() %></p>
            <p><%= evt.getDescription() %></p>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <p>Aucune inscription à un événement futur.</p>
    <% } %>

</div>
</body>
</html>