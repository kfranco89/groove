<?php

namespace STS\Notifications;

use  STS\Services\Notifications\BaseNotification;
use  STS\Services\Notifications\Channels\MailChannel;
use  STS\Services\Notifications\Channels\PushChannel;
use  STS\Services\Notifications\Channels\DatabaseChannel;
use  STS\Services\Notifications\Channels\FacebookChannel;

class AcceptPassengerNotification extends BaseNotification
{
    protected $via = [DatabaseChannel::class, MailChannel::class, PushChannel::class, FacebookChannel::class];

    public function toEmail($user)
    {
        return [
            'title' => $this->getAttribute('from')->name.' ha aceptado tu solicitud.',
            'email_view' => 'passenger_email',
            'type' => 'accept',
            'reason_message' => 'ha aceptado',
            'url' => config('app.url').'/app/trips/'.$this->getAttribute('trip')->id,
        ];
    }

    public function toString()
    {
        return $this->getAttribute('from')->name.' ha aceptado tu solicitud.';
    }

    public function getExtras()
    {
        return [
            'type' => 'trip',
            'trip_id' => $this->getAttribute('trip')->id,
        ];
    }

    public function toPush($user, $device)
    {
        $trip = $this->getAttribute('trip');

        return [
            'message' => $this->getAttribute('from')->name.' ha aceptado tu solicitud.',
            'url' => "trips/" . $trip->id,
            'extras' => [
                'id' => $trip->id,
            ],
            "image" => "https://carpoolear.com.ar/app/static/img/carpoolear_logo.png"
        ];
    }
}
