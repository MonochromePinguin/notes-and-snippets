<!-- this is a hidden form for file renaming, triggered by JS -->
<!---->
<div class="modal fade" id="rename-dialog" tabindex="-1"
     role="dialog" aria-hidden="true">

    <div class="modal-dialog">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close float-left"
                        data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times</span>
                </button>
                <h1 class="modal-title">
                    Renommer «
                    <span class="text-primary file-name"></span> <!-- filled by JS -->
                    »
                </h1>
            </div>

            <!-- the destination URL waits for two name/value pairs in the POST:
                    "action", and "target-name" (the target file's name) -->
            <form method="POST" action="/ajaxHandler.php" class="m-3 container-fluid">

                <div class="row modal-body">
                    <p class="text-info">
                        ancien nom :
                        <span class="file-name"></span> <!-- filled by JS -->
                    </p>

                    <label>
                        nouveau nom :
                        <input type="text" class="focus-on-open" id="target-name"
                               name="target-name" placeholder=""> <!-- filled by JS -->
                    </label>
                </div> <!-- .row.modal-body -->

                <input type="hidden" name="action" value="rename">

                <div class="row modal-footer">
                    <button class="m-3 btn btn-primary">
                        Renommer
                    </button>

                    <button type="button" id="abort-rename-button"
                            class="m-3 btn btn-secondary"
                            data-dismiss="modal" aria-label="Close">
                        Annuler
                    </button>
                </div> <!-- .row.modal-footer -->

            </form> <!-- form.container-fluid -->

        </div> <!-- .modal-content -->
    </div> <!-- .modal-dialog -->
</div> <!-- .modal-fade -->


<!-- this is a hidden form for deletion confirmation, triggered by JS -->
<!---->
<div class="modal fade" id="delete-dialog" tabindex="-1"
     role="dialog" aria-hidden="true">

    <div class="modal-dialog">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close float-left"
                        data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times</span>
                </button>
                <h1 class="modal-title text-danger">
                    Supprimer
                    <span class="visible-when-dir"> récursivement le dossier </span>
                    «
                    <span class="text-primary file-name"></span> <!-- filled by JS -->
                    » ?
                </h1>
            </div>

            <!-- the destination URL waits for two name/value pairs in the POST:
                     "action", and "target-name" (the target file's name) -->
            <form method="POST" action="/ajaxHandler.php" class="m-3 container-fluid">

                <input type="hidden" name="target-name" id="target-name"
                       value=""> <!-- filled by JS -->

                <input type="hidden" name="action" value="delete">

                <div class="row modal-footer">
                    <button class="m-3 btn btn-danger">
                        <span class="badge badge-light">
                            <img src="/assets/images/trashcan.svg" alt="">
                        </span>
                        SUPPRIMER
                    </button>

                    <button type="button" id="abort-rename-button"
                            class="m-3 btn btn-secondary focus-on-open"
                            data-dismiss="modal" aria-label="Close">
                        Annuler
                    </button>
                </div> <!-- .row.modal-footer -->

            </form> <!-- form.container-fluid -->

        </div> <!-- .modal-content -->
    </div> <!-- .modal-dialog -->
</div> <!-- .modal-fade -->
